import 'package:flutter/material.dart';
import 'pdf_paginator_controller.dart';
import 'pdf_paginator_widget.dart';

/// Example of how to use the PDF Paginator Widget in other projects
class ExampleUsage extends StatefulWidget {
  const ExampleUsage({super.key});

  @override
  State<ExampleUsage> createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  late PdfPaginatorController _controller;

  @override
  void initState() {
    super.initState();
    
    // Initialize the controller
    _controller = PdfPaginatorController();
    
    // Set some initial content
    _controller.setText('''
      <h1>My Document</h1>
      <p>This is a sample document created with the PDF Paginator Widget.</p>
      <ul>
        <li>Feature 1: Automatic pagination</li>
        <li>Feature 2: Zoom controls</li>
        <li>Feature 3: Pop-out window</li>
        <li>Feature 4: Page break detection</li>
      </ul>
    ''');
    
    // Listen for page breaks
    _controller.addListener(_onPageBreaksChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageBreaksChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onPageBreaksChanged() {
    if (_controller.hasPageBreaks) {
      print('Page breaks detected: ${_controller.pageBreaksCount}');
      print('Breaks data: ${_controller.getPageBreaksAsJson()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Paginator Example'),
        actions: [
          // Zoom controls in app bar
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _controller.zoomOut,
          ),
          Text('${(_controller.zoomLevel * 100).round()}%'),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _controller.zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.resetZoom,
          ),
          // Pop-out control
          IconButton(
            icon: Icon(_controller.isPopupOpen ? Icons.close : Icons.open_in_new),
            onPressed: _controller.isPopupOpen 
                ? _controller.closePopup 
                : _controller.openPopup,
          ),
        ],
      ),
      body: Column(
        children: [
          // Control panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Example: Update content programmatically
                    _controller.setText('''
                      <h1>Updated Content</h1>
                      <p>This content was updated at ${DateTime.now()}</p>
                      <p>Current zoom: ${(_controller.zoomLevel * 100).round()}%</p>
                      <p>Popup open: ${_controller.isPopupOpen}</p>
                    ''');
                  },
                  child: const Text('Update Content'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Example: Get page breaks
                    if (_controller.hasPageBreaks) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Found ${_controller.pageBreaksCount} page breaks'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No page breaks detected')),
                      );
                    }
                  },
                  child: const Text('Check Page Breaks'),
                ),
                const Spacer(),
                Text('Status: ${_controller.isPopupOpen ? "Popup Open" : "Embedded Mode"}'),
              ],
            ),
          ),
          // PDF Widget
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PdfPaginatorWidget(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example of controller usage patterns:
class ControllerExamples {
  late PdfPaginatorController controller;

  void initializeController() {
    controller = PdfPaginatorController();
  }

  void setDocumentContent() {
    // Set HTML content
    controller.setText('<h1>My Document</h1><p>Content here...</p>');
  }

  void handleZoom() {
    // Zoom operations
    controller.zoomIn();      // Zoom in by 10%
    controller.zoomOut();     // Zoom out by 10%
    controller.setZoom(1.5);  // Set specific zoom level
    controller.resetZoom();   // Reset to 100%
    
    // Get current zoom
    double currentZoom = controller.zoomLevel;
    print('Current zoom: ${(currentZoom * 100).round()}%');
  }

  void handlePopup() {
    // Popup operations
    if (!controller.isPopupOpen) {
      controller.openPopup();   // Open popup window
    }
    
    // Check popup status
    bool isOpen = controller.isPopupOpen;
    bool hasWindow = controller.hasPopupWindow;
    
    if (controller.isPopupOpen) {
      controller.closePopup();  // Close popup window
    }
  }

  void handlePageBreaks() {
    // Get page breaks
    List<Map<String, dynamic>> breaks = controller.pageBreaks;
    int breakCount = controller.pageBreaksCount;
    bool hasBreaks = controller.hasPageBreaks;
    String jsonData = controller.getPageBreaksAsJson();
    
    print('Page breaks: $breakCount');
    print('Has breaks: $hasBreaks');
    print('JSON data: $jsonData');
  }

  void listenToChanges() {
    // Listen for controller changes
    controller.addListener(() {
      print('Controller state changed');
      print('Zoom: ${controller.zoomLevel}');
      print('Popup open: ${controller.isPopupOpen}');
      print('Page breaks: ${controller.pageBreaksCount}');
    });
  }

  void cleanup() {
    // Always dispose the controller
    controller.dispose();
  }
}
