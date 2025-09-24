import 'package:flutter/material.dart';
import 'pdf_paginator_widget.dart';
import 'pdf_paginator_controller.dart';

/// Demo showing how to use the new settings controls
class SettingsDemo extends StatefulWidget {
  const SettingsDemo({super.key});

  @override
  State<SettingsDemo> createState() => _SettingsDemoState();
}

class _SettingsDemoState extends State<SettingsDemo> {
  late PdfPaginatorController controller;

  @override
  void initState() {
    super.initState();
    controller = PdfPaginatorController();
    
    // Set content that showcases all the new configurable elements
    controller.setHtmlContent('''
<h1>Settings Panel Demo</h1>
<p>This demo showcases all the new controls available in the settings panel.</p>

<h2>Line Break Testing</h2>
<p>Adjust "Line Break Height" in settings to see changes:</p>
<p>Line 1<br>Line 2 with break<br>Line 3 with break<br>Line 4</p>

<h2>Anchor Link Testing</h2>
<p>Adjust "Line Height (a)" to control link spacing:</p>
<p>Visit <a href="#">this link</a> and <a href="#">another link</a> for testing.</p>
<p>Multiple <a href="#">links</a> in <a href="#">one</a> paragraph <a href="#">here</a>.</p>

<h2>List Margin Testing</h2>
<p>Adjust UL/OL margin settings to see spacing changes:</p>

<h3>Unordered List</h3>
<ul>
  <li>First item</li>
  <li>Second item with <a href="#">link</a></li>
  <li>Third item</li>
</ul>
<p>Text after UL to see bottom margin effect.</p>

<h3>Ordered List</h3>
<ol>
  <li>First numbered item</li>
  <li>Second with <a href="#">embedded link</a></li>
  <li>Third numbered item</li>
</ol>
<p>Text after OL to see bottom margin effect.</p>

<h2>Combined Elements</h2>
<p>Testing all elements together:</p>
<ul>
  <li>List item<br>with line break</li>
  <li>Item with <a href="#">link spacing</a></li>
</ul>
<ol>
  <li>Numbered item<br>also with break</li>
  <li>With <a href="#">anchor control</a></li>
</ol>

<p>Final test: <a href="#">link</a><br>with break<br>combination.</p>
''');
    
    // Set an initial interesting configuration
    controller.updateConfig(const PdfPaginatorConfig(
      brHeight: 20.0, // Line break spacing (margin-top)
      ulMarginTop: 20.0,
      ulMarginBottom: 20.0,
      olMarginTop: 16.0,
      olMarginBottom: 16.0,
      anchorLineHeight: 1.6,
      backgroundColor: '#f8f9fa',
    ));
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
        title: const Text('Settings Panel Demo'),
        backgroundColor: Colors.green.shade100,
        actions: [
          // Quick configuration buttons
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'compact':
                  controller.updateConfig(const PdfPaginatorConfig(
                    brHeight: 2.0, // Minimal line break spacing
                    ulMarginTop: 4.0,
                    ulMarginBottom: 4.0,
                    olMarginTop: 4.0,
                    olMarginBottom: 4.0,
                    anchorLineHeight: 1.1,
                  ));
                  break;
                case 'default':
                  controller.updateConfig(const PdfPaginatorConfig());
                  break;
                case 'spacious':
                  controller.updateConfig(const PdfPaginatorConfig(
                    brHeight: 32.0, // Large line break spacing
                    ulMarginTop: 32.0,
                    ulMarginBottom: 32.0,
                    olMarginTop: 32.0,
                    olMarginBottom: 32.0,
                    anchorLineHeight: 2.0,
                  ));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'compact',
                child: Text('Compact Layout'),
              ),
              const PopupMenuItem(
                value: 'default',
                child: Text('Default Layout'),
              ),
              const PopupMenuItem(
                value: 'spacious',
                child: Text('Spacious Layout'),
              ),
            ],
            child: const Icon(Icons.settings),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: controller.zoomOut,
          ),
          Text('${(controller.zoomLevel * 100).round()}%'),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: controller.zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: controller.openPopup,
            tooltip: 'Pop Out (Settings available in HTML)',
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings Panel Controls',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('• Click the settings icon (⚙️) in the HTML view to access all controls'),
                Text('• Adjust "Line Break Spacing" to control <br> and <br/> spacing'),
                Text('• Modify "Line Height (a)" for anchor link spacing'),
                Text('• Control UL/OL margins independently'),
                Text('• Use the dropdown above for quick presets'),
              ],
            ),
          ),
          
          // PDF Widget
          Expanded(
            child: PdfPaginatorWidget(controller: controller),
          ),
        ],
      ),
    );
  }
}
