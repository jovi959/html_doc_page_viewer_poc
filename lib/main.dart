import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Paginator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PdfPaginatorScreen(),
    );
  }
}

class PdfPaginatorScreen extends StatefulWidget {
  const PdfPaginatorScreen({super.key});

  @override
  State<PdfPaginatorScreen> createState() => _PdfPaginatorScreenState();
}

class _PdfPaginatorScreenState extends State<PdfPaginatorScreen> {
  final TextEditingController _htmlController = TextEditingController();
  final String _iframeId = 'pdf-preview-iframe';
  double _zoomLevel = 1.0;
  String _paginationData = '';
  bool _isLoading = true;
  html.WindowBase? _popupWindow;
  bool _isPopupMode = false;

  @override
  void initState() {
    super.initState();
    _initializeIframe();
    _setupMessageListener();
    
    // Set default HTML content
    _htmlController.text = '''<h1>Sample Document</h1>
<p>This is a sample paragraph with <strong>bold text</strong> and <em>italic text</em>. This text will be used to test the pagination functionality.</p>
<h2>Features</h2>
<ul>
    <li>Automatic pagination based on page height</li>
    <li>Split detection for long content</li>
    <li>JSON logging of page breaks</li>
    <li>Real-time updates</li>
</ul>
<p>Add more content here to test pagination across multiple pages. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>''';
  }

  void _initializeIframe() {
    if (kIsWeb) {
      // Register the iframe element
      ui.platformViewRegistry.registerViewFactory(_iframeId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'pdf_preview.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..id = 'pdf-iframe';
        
        // Wait for iframe to load
        iframe.onLoad.listen((_) {
          setState(() {
            _isLoading = false;
          });
        });
        
        return iframe;
      });
    }
  }

  void _setupMessageListener() {
    if (kIsWeb) {
      html.window.addEventListener('message', (event) {
        final messageEvent = event as html.MessageEvent;
        try {
          final data = json.decode(messageEvent.data);
          if (data['type'] == 'paginationData') {
            setState(() {
              _paginationData = const JsonEncoder.withIndent('  ').convert(data['payload']);
            });
          }
        } catch (e) {
          // Handle non-JSON messages
          print('Received non-JSON message: ${messageEvent.data}');
        }
      });
    }
  }

  void _updateContent() {
    if (kIsWeb) {
      final message = {
        'action': 'updateContent',
        'html': _htmlController.text,
      };
      
      if (_isPopupMode && _popupWindow != null && !_popupWindow!.closed!) {
        // Send to popup window
        print('Sending update to popup: ${_htmlController.text.substring(0, 50)}...');
        _popupWindow!.postMessage(json.encode(message), '*');
      } else {
        // Send to iframe
        final iframe = html.document.getElementById('pdf-iframe') as html.IFrameElement?;
        if (iframe?.contentWindow != null) {
          print('Sending update to iframe: ${_htmlController.text.substring(0, 50)}...');
          iframe!.contentWindow!.postMessage(json.encode(message), '*');
        }
      }
    }
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0);
    });
    _applyZoom();
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0);
    });
    _applyZoom();
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
    _applyZoom();
  }

  void _applyZoom() {
    if (kIsWeb) {
      final message = {
        'action': 'setZoom',
        'zoom': _zoomLevel,
      };
      
      if (_isPopupMode && _popupWindow != null && !_popupWindow!.closed!) {
        // Send to popup window
        _popupWindow!.postMessage(json.encode(message), '*');
      } else {
        // Send to iframe
        final iframe = html.document.getElementById('pdf-iframe') as html.IFrameElement?;
        if (iframe?.contentWindow != null) {
          iframe!.contentWindow!.postMessage(json.encode(message), '*');
        }
      }
    }
  }

  void _openPopup() {
    if (kIsWeb) {
      // Close existing popup if open
      if (_popupWindow != null && !_popupWindow!.closed!) {
        _popupWindow!.close();
      }
      
      // Open new popup window
      _popupWindow = html.window.open(
        'pdf_preview.html?mode=popup', 
        'pdfPreview', 
        'width=1200,height=800,scrollbars=yes,resizable=yes'
      );
      
      if (_popupWindow != null) {
        setState(() {
          _isPopupMode = true;
        });
        
        // Set up popup ready listener
        _waitForPopupReady();
        
        // Monitor popup window
        _monitorPopup();
      }
    }
  }

  void _waitForPopupReady() {
    // Listen for popup ready message
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      try {
        final data = json.decode(messageEvent.data);
        if (data['type'] == 'popupReady') {
          print('Popup is ready, sending initial content');
          // Send initial content and settings
          _sendInitialDataToPopup();
        }
      } catch (e) {
        // Ignore non-JSON messages
      }
    });
  }

  void _sendInitialDataToPopup() {
    if (_popupWindow != null && !_popupWindow!.closed!) {
      // Send current HTML content
      final contentMessage = {
        'action': 'updateContent',
        'html': _htmlController.text,
      };
      _popupWindow!.postMessage(json.encode(contentMessage), '*');
      
      // Send current zoom level
      final zoomMessage = {
        'action': 'setZoom',
        'zoom': _zoomLevel,
      };
      _popupWindow!.postMessage(json.encode(zoomMessage), '*');
      
      print('Sent initial data to popup: ${_htmlController.text.length} chars');
    }
  }

  void _closePopup() {
    if (_popupWindow != null && !_popupWindow!.closed!) {
      _popupWindow!.close();
    }
    setState(() {
      _isPopupMode = false;
      _popupWindow = null;
    });
  }

  void _monitorPopup() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_popupWindow == null || _popupWindow!.closed!) {
        setState(() {
          _isPopupMode = false;
          _popupWindow = null;
        });
        timer.cancel();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Paginator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          Text(
            '${(_zoomLevel * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left panel - HTML input
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'HTML Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _htmlController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Paste your HTML content here...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updateContent,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Update Preview'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isPopupMode ? _closePopup : _openPopup,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: _isPopupMode ? Colors.orange : null,
                        ),
                        icon: Icon(_isPopupMode ? Icons.close_fullscreen : Icons.open_in_new),
                        label: Text(_isPopupMode ? 'Close Popup' : 'Pop Out'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pagination Data (JSON)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _paginationData.isEmpty 
                              ? 'No pagination data yet...' 
                              : _paginationData,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right panel - PDF preview iframe
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'PDF Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isPopupMode) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'POPUP MODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_isPopupMode)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              if (kIsWeb)
                                HtmlElementView(
                                  viewType: _iframeId,
                                ),
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_isPopupMode)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'PDF Preview opened in popup window',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use the controls here to update content and zoom',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _closePopup,
                                icon: const Icon(Icons.close),
                                label: const Text('Close Popup'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _htmlController.dispose();
    if (_popupWindow != null && !_popupWindow!.closed!) {
      _popupWindow!.close();
    }
    super.dispose();
  }
}
