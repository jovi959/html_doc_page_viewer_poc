import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'pdf_paginator_controller.dart';

/// A widget that provides PDF pagination functionality with HTML content
class PdfPaginatorWidget extends StatefulWidget {
  final PdfPaginatorController controller;
  final String? iframeId;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const PdfPaginatorWidget({
    super.key,
    required this.controller,
    this.iframeId,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
  });

  @override
  State<PdfPaginatorWidget> createState() => _PdfPaginatorWidgetState();
}

class _PdfPaginatorWidgetState extends State<PdfPaginatorWidget> {
  late String _iframeId;
  Timer? _popupMonitorTimer;
  Timer? _initTimeoutTimer;
  Timer? _forceRetryTimer;
  Timer? _iframeReadyPollingTimer;
  String _lastHtmlContent = '';
  double _lastZoomLevel = 1.0;
  bool _lastPopupState = false;
  PdfPaginatorConfig? _lastConfig;
  bool _iframeInitialized = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _iframeId = widget.iframeId ?? 'pdf-preview-iframe-${DateTime.now().millisecondsSinceEpoch}';
    
    // Initialize tracking variables
    _lastHtmlContent = widget.controller.htmlContent;
    _lastZoomLevel = widget.controller.zoomLevel;
    _lastPopupState = widget.controller.isPopupOpen;
    
    if (kIsWeb) {
      // Set loading state initially using post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.setLoading(true);
      });
      _initializeIframe();
      _setupMessageListener();
      
      // Fallback timeout in case iframe never loads
      // _initTimeoutTimer = Timer(const Duration(seconds: 10), () {
      //   if (!_disposed && widget.controller.isLoading && !_iframeInitialized) {
      //     debugPrint('Iframe load timeout, forcing loading to false');
      //     widget.controller.setLoading(false);
      //     _iframeInitialized = true;
          
      //     // Try to send initial content anyway
      //     Timer(const Duration(milliseconds: 500), () {
      //       if (!_disposed && widget.controller.htmlContent.isNotEmpty) {
      //         _sendMessageToIframe({
      //           'action': 'updateContent',
      //           'html': widget.controller.htmlContent,
      //         });
      //       }
      //       if (!_disposed) {
      //         _sendMessageToIframe({
      //           'action': 'setZoom',
      //           'zoom': widget.controller.zoomLevel,
      //         });
      //       }
      //     });
      //   }
      // });
    } else {
      // Set loading state using post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.setLoading(false);
      });
    }
    
    // Listen to controller changes
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    debugPrint('Disposing PdfPaginatorWidget');
    _disposed = true;
    
    // Remove controller listener
    widget.controller.removeListener(_onControllerChange);
    
    // Cancel all timers
    _popupMonitorTimer?.cancel();
    _initTimeoutTimer?.cancel();
    _forceRetryTimer?.cancel();
    _iframeReadyPollingTimer?.cancel();
    
    // Clear references
    _popupMonitorTimer = null;
    _initTimeoutTimer = null;
    _forceRetryTimer = null;
    _iframeReadyPollingTimer = null;
    
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
      
      // Only update if something actually changed
      if (kIsWeb) {
        if (widget.controller.htmlContent != _lastHtmlContent) {
          _lastHtmlContent = widget.controller.htmlContent;
          _updateContent();
        }
        
        if (widget.controller.zoomLevel != _lastZoomLevel) {
          _lastZoomLevel = widget.controller.zoomLevel;
          _applyZoom();
        }

        if (widget.controller.config != _lastConfig) {
          _lastConfig = widget.controller.config;
          _updateConfig();
        }

        // Check for popup open/close requests
        if (widget.controller.isPopupOpen != _lastPopupState) {
          _lastPopupState = widget.controller.isPopupOpen;
          if (widget.controller.isPopupOpen && widget.controller.popupWindow != null) {
            // Controller created a popup - start monitoring and send initial data
            debugPrint('Controller opened popup, starting monitoring and sending initial data');
            _monitorPopup();
            
            // Send initial data after a short delay to ensure popup is loaded
            Timer(const Duration(milliseconds: 1000), () {
              if (!_disposed && widget.controller.isPopupOpen) {
                _sendInitialDataToPopup();
              }
            });
          }
        }
      }
    }
  }

  void _initializeIframe() {
    debugPrint('Initializing iframe with id: $_iframeId');
    
    // Create iframe element
    final iframe = web.HTMLIFrameElement()
      ..src = 'pdf_preview.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..id = _iframeId;

    // Register the iframe with Flutter's platform view system
    debugPrint('Registering iframe view factory');
    ui.platformViewRegistry.registerViewFactory(_iframeId, (int viewId) => iframe);
    
    // Start polling to detect when the iframe is ready
    _startIframeReadyPolling();
    
      // Set up fallback timeout as ultimate safety net
      _initTimeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!_disposed && widget.controller.isLoading && !_iframeInitialized) {
          debugPrint('Iframe initialization timeout after 15 seconds, using fallback approach');
          _handleIframeReady(isTimeout: true);
        }
      });
  }
  
  void _startIframeReadyPolling() {
    debugPrint('Starting iframe ready polling for ID: $_iframeId');
    int pollCount = 0;
    
    // Poll every 200ms to check if iframe is ready
    _iframeReadyPollingTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_disposed) {
        debugPrint('Widget disposed, stopping polling');
        timer.cancel();
        return;
      }
      
      if (_iframeInitialized) {
        debugPrint('Iframe already initialized, stopping polling');
        timer.cancel();
        return;
      }
      
      pollCount++;
      if (pollCount % 10 == 0) {
        debugPrint('Polling attempt #$pollCount, looking for iframe with ID: $_iframeId');
        // List all iframes in the document for debugging
        final allIframes = web.document.querySelectorAll('iframe');
        debugPrint('Found ${allIframes.length} iframes in document');
        for (int i = 0; i < allIframes.length; i++) {
          final iframe = allIframes.item(i) as web.HTMLIFrameElement?;
          debugPrint('  Iframe $i: id="${iframe?.id}", src="${iframe?.src}"');
        }
      }
      
      // Try to find the iframe in the DOM
      final iframe = web.document.getElementById(_iframeId) as web.HTMLIFrameElement?;
      if (iframe != null) {
        debugPrint('Found iframe with ID $_iframeId, contentWindow: ${iframe.contentWindow != null}');
        
        if (iframe.contentWindow != null) {
          // Check if we can access the iframe's document (indicates it's loaded)
          try {
            // Try to send a test message to see if the iframe is responsive
            iframe.contentWindow!.postMessage('{"action": "ping"}'.toJS, '*'.toJS);
            
            // If we get here without error, the iframe is likely ready
            debugPrint('Iframe appears to be accessible, sent ping message, waiting for response or ready message');
            timer.cancel();
            
            // Set a shorter timeout now that we know the iframe exists
            Timer(const Duration(seconds: 3), () {
              if (!_disposed && !_iframeInitialized) {
                debugPrint('Iframe exists but no ready message received after 3 seconds, proceeding anyway');
                _handleIframeReady(isTimeout: false);
              }
            });
            
          } catch (e) {
            // Iframe not ready yet, continue polling
            debugPrint('Iframe found but not ready yet: $e');
          }
        } else {
          debugPrint('Iframe found but contentWindow is null');
        }
      } else {
        if (pollCount % 20 == 0) {
          debugPrint('Iframe with ID $_iframeId not found in DOM (attempt $pollCount)');
        }
      }
    });
  }
  
  void _handleIframeReady({required bool isTimeout}) {
    if (_disposed || _iframeInitialized) return;
    
    debugPrint('Handling iframe ready (timeout: $isTimeout)');
    _iframeInitialized = true;
    widget.controller.setLoading(false);
    
    // Cancel timeout timer
    _initTimeoutTimer?.cancel();
    
    // Send initial data after a short delay
    Timer(const Duration(milliseconds: 500), () {
      if (!_disposed) {
        debugPrint('Sending initial content to iframe');
        if (widget.controller.htmlContent.isNotEmpty) {
          _sendMessageToIframe({
            'action': 'updateContent',
            'html': widget.controller.htmlContent,
          });
        }
        _sendMessageToIframe({
          'action': 'setZoom',
          'zoom': widget.controller.zoomLevel,
        });
        _sendMessageToIframe({
          'action': 'updateConfig',
          'config': widget.controller.config.toJson(),
        });
      }
    });
  }


  void _setupMessageListener() {
    web.window.addEventListener('message', (web.Event event) {
      if (_disposed) return;
      
      try {
        final messageEvent = event as web.MessageEvent;
        final data = json.decode(messageEvent.data.toString()) as Map<String, dynamic>;
        
        if (data['type'] == 'paginationData') {
          final payload = data['payload'] as List<dynamic>;
          final breaks = payload.cast<Map<String, dynamic>>();
          if (!_disposed) {
            widget.controller.updatePageBreaks(breaks);
          }
        } else if (data['type'] == 'zoomChanged') {
          // Update zoom level without triggering change notifications
          final newZoom = data['zoom'].toDouble();
          if (!_disposed) {
            widget.controller.updateZoomFromExternal(newZoom);
            _lastZoomLevel = newZoom; // Update tracking variable
          }
        } else if (data['type'] == 'requestPopout') {
          if (!_disposed) {
            widget.controller.openPopup();
          }
        } else if (data['type'] == 'popupReady') {
          // Popup is ready, send initial data immediately
          if (!_disposed) {
            _sendInitialDataToPopup();
          }
        } else if (data['type'] == 'iframeReady') {
          // Iframe is ready and loaded
          debugPrint('Received iframeReady message');
          if (!_disposed && !_iframeInitialized) {
            _handleIframeReady(isTimeout: false);
          }
        } else if (data['action'] == 'pong') {
          // Response to our ping - iframe is responsive
          debugPrint('Received pong response, iframe is responsive');
          if (!_disposed && !_iframeInitialized) {
            _handleIframeReady(isTimeout: false);
          }
        }
      } catch (e) {
        debugPrint('Error parsing message: $e');
      }
    }.toJS);
  }

  void _updateContent() {
    debugPrint('_updateContent called with content length: ${widget.controller.htmlContent.length}');
    if (widget.controller.htmlContent.isNotEmpty) {
      final message = {
        'action': 'updateContent',
        'html': widget.controller.htmlContent,
      };

      debugPrint('Sending updateContent message to iframe');
      // Send to iframe
      _sendMessageToIframe(message);

      // Send to popup if open
      if (widget.controller.isPopupOpen) {
        debugPrint('Also sending to popup');
        _sendMessageToPopup(message);
      }
    } else {
      debugPrint('HTML content is empty, not sending update');
    }
  }

  void _sendMessageToIframe(Map<String, dynamic> message) {
    if (_disposed) {
      debugPrint('Widget disposed, skipping iframe message');
      return;
    }
    
    debugPrint('Attempting to send message to iframe. Initialized: $_iframeInitialized');
    if (!_iframeInitialized) {
      debugPrint('Iframe not initialized, skipping message');
      return;
    }
    
    final iframe = web.document.getElementById(_iframeId) as web.HTMLIFrameElement?;
    debugPrint('Found iframe element: ${iframe != null}');
    if (iframe?.contentWindow != null) {
      try {
        iframe!.contentWindow!.postMessage(json.encode(message).toJS, '*'.toJS);
        debugPrint('Message sent to iframe successfully: ${message['action']}');
      } catch (e) {
        debugPrint('Error sending message to iframe: $e');
      }
    } else {
      debugPrint('Iframe contentWindow is null');
    }
  }

  void _sendMessageToPopup(Map<String, dynamic> message) {
    if (_disposed) {
      debugPrint('Widget disposed, skipping popup message');
      return;
    }
    
    final popupWindow = widget.controller.popupWindow;
    if (popupWindow != null && !popupWindow.closed) {
      try {
        popupWindow.postMessage(json.encode(message).toJS, '*'.toJS);
      } catch (e) {
        debugPrint('Error sending message to popup: $e');
      }
    }
  }

  void _applyZoom() {
    final message = {
      'action': 'setZoom',
      'zoom': widget.controller.zoomLevel,
    };

    _sendMessageToIframe(message);
    
    if (widget.controller.isPopupOpen) {
      _sendMessageToPopup(message);
    }
  }

  void _updateConfig() {
    if (_disposed || !_iframeInitialized) return;
    
    debugPrint('Updating config: ${widget.controller.config.toJson()}');
    final message = {
      'action': 'updateConfig',
      'config': widget.controller.config.toJson(),
    };

    _sendMessageToIframe(message);
    
    if (widget.controller.isPopupOpen) {
      _sendMessageToPopup(message);
    }
  }

  void _sendInitialDataToPopup() {
    if (!widget.controller.isPopupOpen) return;

    debugPrint('Sending initial data to popup');
    
    // Send HTML content
    if (widget.controller.htmlContent.isNotEmpty) {
      final contentMessage = {
        'action': 'updateContent',
        'html': widget.controller.htmlContent,
      };
      _sendMessageToPopup(contentMessage);
    }

    // Send zoom level
    _sendMessageToPopup({
      'action': 'setZoom',
      'zoom': widget.controller.zoomLevel,
    });

    // Send configuration
    _sendMessageToPopup({
      'action': 'updateConfig',
      'config': widget.controller.config.toJson(),
    });

    // Send current zoom level
    final zoomMessage = {
      'action': 'setZoom',
      'zoom': widget.controller.zoomLevel,
    };
    _sendMessageToPopup(zoomMessage);

    debugPrint('Sent initial data to popup: ${widget.controller.htmlContent.length} chars');
  }

  void _monitorPopup() {
    _popupMonitorTimer?.cancel();
    debugPrint('Starting popup monitoring...');
    _popupMonitorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_disposed) {
        debugPrint('Widget disposed, stopping popup monitoring');
        timer.cancel();
        return;
      }
      
      final popup = widget.controller.popupWindow;
      if (popup != null) {
        try {
          // Try to access the popup's closed property
          final isClosed = popup.closed;
          debugPrint('Popup status check - closed: $isClosed');
          
          if (isClosed == true) {
            debugPrint('Popup closed detected, syncing embedded iframe');
            
            // Trigger sync before clearing the reference
            _syncEmbeddedIframeAfterPopupClose();
            
            // Clear the programmatic closing flag if it was set
            if (widget.controller.isPopupClosingProgrammatically) {
              debugPrint('Programmatic close detected, clearing flag');
              widget.controller.clearProgrammaticCloseFlag();
            }
            
            widget.controller.setPopupWindow(null);
            timer.cancel();
          }
        } catch (e) {
          // If we can't access the popup, it's likely closed
          debugPrint('Error checking popup status (likely closed): $e');
          _syncEmbeddedIframeAfterPopupClose();
          
          // Clear the programmatic closing flag if it was set
          if (widget.controller.isPopupClosingProgrammatically) {
            widget.controller.clearProgrammaticCloseFlag();
          }
          
          widget.controller.setPopupWindow(null);
          timer.cancel();
        }
      } else {
        // Check if this was a programmatic close that needs sync
        if (widget.controller.isPopupClosingProgrammatically) {
          debugPrint('Programmatic close with null popup, syncing embedded iframe');
          _syncEmbeddedIframeAfterPopupClose();
          widget.controller.clearProgrammaticCloseFlag();
        }
        
        debugPrint('No popup window reference, stopping monitoring');
        timer.cancel();
      }
    });
  }

  void _syncEmbeddedIframeAfterPopupClose() {
    if (_disposed || !_iframeInitialized) {
      debugPrint('Cannot sync: disposed=$_disposed, initialized=$_iframeInitialized');
      return;
    }
    
    debugPrint('Scheduling iframe sync after popup closure...');
    
    // Small delay to allow popup to fully close and ensure DOM is ready
    Timer(const Duration(milliseconds: 500), () {
      if (_disposed) {
        debugPrint('Widget disposed during sync delay, aborting');
        return;
      }
      
      debugPrint('Syncing embedded iframe after popup closure');
      debugPrint('Current content length: ${widget.controller.htmlContent.length}');
      debugPrint('Current zoom: ${widget.controller.zoomLevel}');
      
      // Send current HTML content
      if (widget.controller.htmlContent.isNotEmpty) {
        debugPrint('Sending content update to embedded iframe');
        _sendMessageToIframe({
          'action': 'updateContent',
          'html': widget.controller.htmlContent,
        });
        
        // Give a small delay between messages
        Timer(const Duration(milliseconds: 100), () {
          if (_disposed) return;
          
          // Send current zoom level
          debugPrint('Sending zoom update to embedded iframe: ${widget.controller.zoomLevel}');
          _sendMessageToIframe({
            'action': 'setZoom',
            'zoom': widget.controller.zoomLevel,
          });

          // Send current config
          debugPrint('Sending config update to embedded iframe');
          _sendMessageToIframe({
            'action': 'updateConfig',
            'config': widget.controller.config.toJson(),
          });
          
          // Force a re-pagination to ensure everything is up to date
          Timer(const Duration(milliseconds: 100), () {
            if (_disposed) return;
            
            debugPrint('Triggering repagination in embedded iframe');
            _sendMessageToIframe({
              'action': 'repaginate',
            });
          });
        });
      } else {
        debugPrint('No content to sync - htmlContent is empty');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        color: widget.backgroundColor ?? Colors.grey[200],
        child: const Center(
          child: Text(
            'PDF Paginator is only available on web platform',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.controller.isPopupOpen
          ? _buildPopupPlaceholder()
          : _buildIframeView(),
    );
  }

  Widget _buildIframeView() {
    return Stack(
      children: [
        // Always render the HtmlElementView so the iframe gets added to DOM
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: HtmlElementView(viewType: _iframeId),
        ),
        // Show loading indicator on top while loading
        if (widget.controller.isLoading)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildPopupPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.open_in_new,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'PDF Preview opened in separate window',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Controls and content updates are synchronized',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.controller.closePopup,
            icon: const Icon(Icons.close),
            label: const Text('Close Popup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}
