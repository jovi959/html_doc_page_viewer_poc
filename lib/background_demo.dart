import 'package:flutter/material.dart';
import 'pdf_paginator_widget.dart';
import 'pdf_paginator_controller.dart';

class BackgroundDemo extends StatefulWidget {
  const BackgroundDemo({super.key});

  @override
  State<BackgroundDemo> createState() => _BackgroundDemoState();
}

class _BackgroundDemoState extends State<BackgroundDemo> {
  late PdfPaginatorController controller;

  @override
  void initState() {
    super.initState();
    controller = PdfPaginatorController();
    
    // Set demo content and configuration
    controller.setHtmlContent('''
<h1>Background Configuration Demo</h1>
<p>This demo shows how to configure the HTML background and page settings from Flutter.</p>

<h2>Features</h2>
<ul>
  <li>Background color control from Flutter</li>
  <li>Page background color configuration</li>
  <li>Margin settings from Flutter code</li>
  <li>Font size and line height settings</li>
</ul>

<h2>Configuration Object</h2>
<p>Use the <code>PdfPaginatorConfig</code> class to set all parameters from Flutter:</p>
<ul>
  <li><strong>Margins:</strong> marginTop, marginBottom, marginLeft, marginRight</li>
  <li><strong>Font settings:</strong> fontSize, lineHeight, liLineHeight</li>
  <li><strong>Colors:</strong> backgroundColor (HTML), pageBackgroundColor (pages)</li>
</ul>

<p>Try the different background color buttons below to see the effect!</p>
''');

    // Initial configuration with custom settings
    controller.updateConfig(const PdfPaginatorConfig(
      marginTop: 30.0,
      marginBottom: 30.0,
      marginLeft: 25.0,
      marginRight: 25.0,
      fontSize: 14.0,
      backgroundColor: '#e3f2fd', // Light blue background
      pageBackgroundColor: '#ffffff', // White pages
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
        title: const Text('Background & Config Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Background color controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HTML Background Colors:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: controller.config.marginTop,
                              marginBottom: controller.config.marginBottom,
                              marginLeft: controller.config.marginLeft,
                              marginRight: controller.config.marginRight,
                              fontSize: controller.config.fontSize,
                              backgroundColor: '#ffffff', // White
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          child: const Text('White', style: TextStyle(color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: controller.config.marginTop,
                              marginBottom: controller.config.marginBottom,
                              marginLeft: controller.config.marginLeft,
                              marginRight: controller.config.marginRight,
                              fontSize: controller.config.fontSize,
                              backgroundColor: '#f0f0f0', // Light gray
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                          child: const Text('Light Gray', style: TextStyle(color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: controller.config.marginTop,
                              marginBottom: controller.config.marginBottom,
                              marginLeft: controller.config.marginLeft,
                              marginRight: controller.config.marginRight,
                              fontSize: controller.config.fontSize,
                              backgroundColor: '#e3f2fd', // Light blue
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
                          child: const Text('Light Blue', style: TextStyle(color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: controller.config.marginTop,
                              marginBottom: controller.config.marginBottom,
                              marginLeft: controller.config.marginLeft,
                              marginRight: controller.config.marginRight,
                              fontSize: controller.config.fontSize,
                              backgroundColor: '#2e2e2e', // Dark gray
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                          child: const Text('Dark', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Margin controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Margin Presets:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: 15.0,
                              marginBottom: 15.0,
                              marginLeft: 15.0,
                              marginRight: 15.0,
                              fontSize: controller.config.fontSize,
                              backgroundColor: controller.config.backgroundColor,
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          child: const Text('Small'),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: 25.0,
                              marginBottom: 25.0,
                              marginLeft: 25.0,
                              marginRight: 25.0,
                              fontSize: controller.config.fontSize,
                              backgroundColor: controller.config.backgroundColor,
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          child: const Text('Medium'),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.updateConfig(
                            PdfPaginatorConfig(
                              marginTop: 40.0,
                              marginBottom: 40.0,
                              marginLeft: 40.0,
                              marginRight: 40.0,
                              fontSize: controller.config.fontSize,
                              backgroundColor: controller.config.backgroundColor,
                              pageBackgroundColor: controller.config.pageBackgroundColor,
                            ),
                          ),
                          child: const Text('Large'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // PDF Paginator
            Expanded(
              child: PdfPaginatorWidget(
                controller: controller,
                backgroundColor: Colors.transparent, // Let HTML background show through
              ),
            ),
          ],
        ),
      ),
    );
  }
}
