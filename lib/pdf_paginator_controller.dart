import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Controller for managing PDF pagination functionality
/// Configuration object for PDF paginator settings
class PdfPaginatorConfig {
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;
  final double fontSize;
  final double lineHeight;
  final double liLineHeight;
  final double brHeight; // Actually controls margin-top spacing
  final double ulMarginTop;
  final double ulMarginBottom;
  final double olMarginTop;
  final double olMarginBottom;
  final double anchorLineHeight;
  final String backgroundColor;
  final String pageBackgroundColor;

  const PdfPaginatorConfig({
    this.marginTop = 20.0,
    this.marginBottom = 20.0,
    this.marginLeft = 20.0,
    this.marginRight = 20.0,
    this.fontSize = 12.0,
    this.lineHeight = 1.5,
    this.liLineHeight = 1.5,
    this.brHeight = 16.0,
    this.ulMarginTop = 16.0,
    this.ulMarginBottom = 16.0,
    this.olMarginTop = 16.0,
    this.olMarginBottom = 16.0,
    this.anchorLineHeight = 1.5,
    this.backgroundColor = '#f5f5f5',
    this.pageBackgroundColor = '#ffffff',
  });

  Map<String, dynamic> toJson() {
    return {
      'marginTop': marginTop,
      'marginBottom': marginBottom,
      'marginLeft': marginLeft,
      'marginRight': marginRight,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'liLineHeight': liLineHeight,
      'brHeight': brHeight,
      'ulMarginTop': ulMarginTop,
      'ulMarginBottom': ulMarginBottom,
      'olMarginTop': olMarginTop,
      'olMarginBottom': olMarginBottom,
      'anchorLineHeight': anchorLineHeight,
      'backgroundColor': backgroundColor,
      'pageBackgroundColor': pageBackgroundColor,
    };
  }
}

class PdfPaginatorController extends ChangeNotifier {
  String _htmlContent = '';
  double _zoomLevel = 1.0;
  List<Map<String, dynamic>> _pageBreaks = [];
  bool _isLoading = true;
  web.Window? _popupWindow;
  PdfPaginatorConfig _config = const PdfPaginatorConfig();
  bool _isPopupMode = false;

  // Getters
  String get htmlContent => _htmlContent;
  double get zoomLevel => _zoomLevel;
  List<Map<String, dynamic>> get pageBreaks => List.unmodifiable(_pageBreaks);
  bool get isLoading => _isLoading;
  bool get isPopupOpen => _isPopupMode && _popupWindow != null && !_popupWindow!.closed;
  bool get hasPopupWindow => _popupWindow != null && !_popupWindow!.closed;
  web.Window? get popupWindow => _popupWindow;
  PdfPaginatorConfig get config => _config;

  /// Set the HTML content for pagination
  void setText(String htmlContent) {
    _htmlContent = htmlContent;
    notifyListeners();
  }

  /// Set HTML content
  void setHtmlContent(String content) {
    if (_htmlContent != content) {
      _htmlContent = content;
      notifyListeners();
    }
  }

  /// Update configuration
  void updateConfig(PdfPaginatorConfig newConfig) {
    if (_config != newConfig) {
      _config = newConfig;
      notifyListeners();
    }
  }

  /// Set the zoom level
  void setZoom(double zoom) {
    _zoomLevel = zoom.clamp(0.5, 3.0);
    notifyListeners();
  }

  /// Zoom in by 0.1
  void zoomIn() {
    setZoom(_zoomLevel + 0.1);
  }

  /// Zoom out by 0.1
  void zoomOut() {
    setZoom(_zoomLevel - 0.1);
  }

  /// Reset zoom to 100%
  void resetZoom() {
    setZoom(1.0);
  }

  /// Open popup window
  void openPopup() {
    if (kIsWeb && !isPopupOpen) {
      final popup = web.window.open(
        'pdf_preview.html?mode=popup',
        '_blank',
        'width=1200,height=800,scrollbars=yes,resizable=yes'
      );
      setPopupWindow(popup);
      // Widget will detect this change and start monitoring
    }
  }

  /// Close popup window
  void closePopup() {
    if (_popupWindow != null && !_popupWindow!.closed) {
      // Mark that this is a programmatic close to trigger sync
      _isPopupClosingProgrammatically = true;
      _popupWindow!.close();
    } else {
      // Already closed or null, just clean up
      setPopupWindow(null);
    }
  }

  bool _isPopupClosingProgrammatically = false;
  
  /// Check if popup is being closed programmatically
  bool get isPopupClosingProgrammatically => _isPopupClosingProgrammatically;
  
  /// Clear the programmatic closing flag
  void clearProgrammaticCloseFlag() {
    _isPopupClosingProgrammatically = false;
  }

  /// Update page breaks data
  void updatePageBreaks(List<Map<String, dynamic>> breaks) {
    if (_pageBreaks.length != breaks.length || 
        _pageBreaks.toString() != breaks.toString()) {
      _pageBreaks = breaks;
      notifyListeners();
    }
  }

  /// Update loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Update zoom level from external source (like HTML controls)
  void updateZoomFromExternal(double zoom) {
    _zoomLevel = zoom.clamp(0.5, 3.0);
    // Don't notify listeners to avoid loops - this is an external update
  }

  /// Set popup window reference
  void setPopupWindow(web.Window? window) {
    _popupWindow = window;
    _isPopupMode = window != null;
    notifyListeners();
  }

  /// Get formatted page breaks as JSON string
  String getPageBreaksAsJson() {
    return const JsonEncoder.withIndent('  ').convert(_pageBreaks);
  }

  /// Get page breaks count
  int get pageBreaksCount => _pageBreaks.length;

  /// Check if content has page breaks
  bool get hasPageBreaks => _pageBreaks.isNotEmpty;

  @override
  void dispose() {
    closePopup();
    super.dispose();
  }
}
