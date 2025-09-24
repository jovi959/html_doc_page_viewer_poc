import 'package:flutter/material.dart';
import 'pdf_paginator_widget.dart';
import 'pdf_paginator_controller.dart';

class EnhancedFeaturesDemo extends StatefulWidget {
  const EnhancedFeaturesDemo({super.key});

  @override
  State<EnhancedFeaturesDemo> createState() => _EnhancedFeaturesDemoState();
}

class _EnhancedFeaturesDemoState extends State<EnhancedFeaturesDemo> {
  late PdfPaginatorController controller;

  @override
  void initState() {
    super.initState();
    controller = PdfPaginatorController();
    
    // Set demo content that showcases all new features
    controller.setHtmlContent('''
<h1>Enhanced PDF Features Demo</h1>
<p>This demo showcases the new configuration options added to the PDF paginator.</p>

<h2>Line Break Testing</h2>
<p>Here we test custom line break heights:</p>
<p>Line 1<br>Line 2 (custom BR height)<br>Line 3<br>Line 4</p>

<h2>Anchor Link Testing</h2>
<p>Testing anchor link line heights with different configurations:</p>
<p>Visit <a href="https://flutter.dev">Flutter</a> for more information.</p>
<p>Also check out <a href="https://dart.dev">Dart</a> programming language.</p>

<h2>Unordered List Testing</h2>
<p>Custom UL margins (top/bottom configurable):</p>
<ul>
  <li>First item in unordered list</li>
  <li>Second item with <a href="#">embedded link</a></li>
  <li>Third item for testing</li>
  <li>Fourth item to show spacing</li>
</ul>

<h2>Ordered List Testing</h2>
<p>Custom OL margins and improved rendering:</p>
<ol>
  <li>First numbered item</li>
  <li>Second numbered item with <a href="#">link</a></li>
  <li>Third numbered item</li>
  <li>Fourth numbered item for margin testing</li>
  <li>Fifth item to demonstrate list continuation</li>
</ol>

<h2>Mixed Content Testing</h2>
<p>Testing all elements together:</p>
<ul>
  <li>List item 1<br>with line break</li>
  <li>List item 2 with <a href="#">link</a></li>
</ul>
<ol>
  <li>Numbered item 1<br>also with break</li>
  <li>Numbered item 2 with <a href="#">another link</a></li>
</ol>

<p>Final paragraph with <a href="#">multiple</a> links and<br>line breaks to test<br>all features together.</p>
''');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Features Demo'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: controller.zoomOut,
            tooltip: 'Zoom Out',
          ),
          Text('${(controller.zoomLevel * 100).round()}%'),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: controller.zoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetZoom,
            tooltip: 'Reset Zoom',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: controller.openPopup,
            tooltip: 'Pop Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configuration Presets:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => controller.updateConfig(const PdfPaginatorConfig(
                        brHeight: 8.0,
                        ulMarginTop: 4.0,
                        ulMarginBottom: 4.0,
                        olMarginTop: 4.0,
                        olMarginBottom: 4.0,
                        anchorLineHeight: 1.1,
                      )),
                      child: const Text('Compact'),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.updateConfig(const PdfPaginatorConfig()),
                      child: const Text('Default'),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.updateConfig(const PdfPaginatorConfig(
                        brHeight: 24.0,
                        ulMarginTop: 24.0,
                        ulMarginBottom: 24.0,
                        olMarginTop: 24.0,
                        olMarginBottom: 24.0,
                        anchorLineHeight: 1.8,
                      )),
                      child: const Text('Spacious'),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.updateConfig(const PdfPaginatorConfig(
                        backgroundColor: '#e8f4f8',
                        pageBackgroundColor: '#ffffff',
                        brHeight: 16.0,
                        ulMarginTop: 12.0,
                        ulMarginBottom: 12.0,
                        olMarginTop: 12.0,
                        olMarginBottom: 12.0,
                      )),
                      child: const Text('Blue Theme'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // PDF Paginator Widget
          Expanded(
            child: PdfPaginatorWidget(controller: controller),
          ),
        ],
      ),
    );
  }
}
