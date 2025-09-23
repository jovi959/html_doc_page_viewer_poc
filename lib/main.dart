import 'package:flutter/material.dart';
import 'pdf_paginator_controller.dart';
import 'pdf_paginator_widget.dart';

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
  late PdfPaginatorController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfPaginatorController();
    
    // Set initial content
    _htmlController.text = '''<h1>Sample Document</h1>
<p>This is a sample paragraph to demonstrate the pagination functionality.</p>

<h2>First Section</h2>
<ul>
<li>First item with some content</li>
<li>Second item with more content</li>
<li>Third item to show list handling</li>
<li>Fourth item for testing</li>
<li>Fifth item with additional text</li>
<li>Sixth item to demonstrate pagination</li>
</ul>

<p>This is another paragraph with some text content. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>

<p>Here's a longer paragraph to test text wrapping and pagination. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>

<p>Final paragraph to complete the sample content.</p>

<h2>Extremely Long List To Test Splitting</h2>
<ul>
<li>List Item 1 - Lorem ipsum dolor sit amet, consectetur adipiscing elit</li>
<li>List Item 2 - Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua</li>
<li>List Item 3 - Ut enim ad minim veniam, quis nostrud exercitation ullamco</li>
<li>List Item 4 - Laboris nisi ut aliquip ex ea commodo consequat</li>
<li>List Item 5 - Duis aute irure dolor in reprehenderit in voluptate</li>
<li>List Item 6 - Velit esse cillum dolore eu fugiat nulla pariatur</li>
<li>List Item 7 - Excepteur sint occaecat cupidatat non proident</li>
<li>List Item 8 - Sunt in culpa qui officia deserunt mollit anim</li>
<li>List Item 9 - Id est laborum sed ut perspiciatis unde omnis</li>
<li>List Item 10 - Iste natus error sit voluptatem accusantium doloremque</li>
<li>List Item 11 - Laudantium totam rem aperiam eaque ipsa quae ab illo</li>
<li>List Item 12 - Inventore veritatis et quasi architecto beatae vitae dicta</li>
<li>List Item 13 - Sunt explicabo nemo enim ipsam voluptatem quia voluptas</li>
<li>List Item 14 - Sit aspernatur aut odit aut fugit sed quia consequuntur</li>
<li>List Item 15 - Magni dolores eos qui ratione voluptatem sequi nesciunt</li>
<li>List Item 16 - Neque porro quisquam est qui dolorem ipsum quia dolor</li>
<li>List Item 17 - Sit amet consectetur adipisci velit sed quia non numquam</li>
<li>List Item 18 - Eius modi tempora incidunt ut labore et dolore magnam</li>
<li>List Item 19 - Aliquam quaerat voluptatem ut enim ad minima veniam</li>
<li>List Item 20 - Quis nostrum exercitationem ullam corporis suscipit</li>
<li>List Item 21 - Laboriosam nisi ut aliquid ex ea commodi consequatur</li>
<li>List Item 22 - Quis autem vel eum iure reprehenderit qui in ea</li>
<li>List Item 23 - Voluptate velit esse quam nihil molestiae consequatur</li>
<li>List Item 24 - Vel illum qui dolorem eum fugiat quo voluptas nulla</li>
<li>List Item 25 - Pariatur at vero eos et accusamus et iusto odio</li>
<li>List Item 26 - Dignissimos ducimus qui blanditiis praesentium voluptatum</li>
<li>List Item 27 - Deleniti atque corrupti quos dolores et quas molestias</li>
<li>List Item 28 - Excepturi sint occaecati cupiditate non provident</li>
<li>List Item 29 - Similique sunt in culpa qui officia deserunt mollitia</li>
<li>List Item 30 - Animi id est laborum et dolorum fuga et harum quidem</li>
<li>List Item 31 - Rerum facilis est et expedita distinctio nam libero</li>
<li>List Item 32 - Tempore cum soluta nobis est eligendi optio cumque</li>
<li>List Item 33 - Nihil impedit quo minus id quod maxime placeat facere</li>
<li>List Item 34 - Possimus omnis voluptas assumenda est omnis dolor</li>
<li>List Item 35 - Repellendus temporibus autem quibusdam et aut officiis</li>
<li>List Item 36 - Debitis aut rerum necessitatibus saepe eveniet ut et</li>
<li>List Item 37 - Voluptates repudiandae sint et molestiae non recusandae</li>
<li>List Item 38 - Itaque earum rerum hic tenetur a sapiente delectus</li>
<li>List Item 39 - Ut aut reiciendis voluptatibus maiores alias consequatur</li>
<li>List Item 40 - Aut perferendis doloribus asperiores repellat</li>
</ul>

<h2>Complex Formatting Test</h2>
<p>This is a very long paragraph designed to test text splitting across pages. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.</p>

<strong>Bold conclusion text to end the document.</strong>''';

    _pdfController.setText(_htmlController.text);
    
    // Listen to controller changes
    _pdfController.addListener(_onPdfControllerChange);
  }

  @override
  void dispose() {
    _pdfController.removeListener(_onPdfControllerChange);
    _pdfController.dispose();
    _htmlController.dispose();
    super.dispose();
  }

  void _onPdfControllerChange() {
    // React to controller changes if needed
    if (mounted) {
      setState(() {});
    }
  }

  void _updatePreview() {
    _pdfController.setText(_htmlController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Paginator Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _pdfController.zoomOut,
            tooltip: 'Zoom Out',
          ),
          Text(
            '${(_pdfController.zoomLevel * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _pdfController.zoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _pdfController.resetZoom,
            tooltip: 'Reset Zoom',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Panel - HTML Input and JSON Output
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'HTML Content:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _htmlController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter HTML content here...',
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updatePreview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Update Preview'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _pdfController.isPopupOpen 
                            ? _pdfController.closePopup 
                            : _pdfController.openPopup,
                        icon: Icon(_pdfController.isPopupOpen ? Icons.close : Icons.open_in_new),
                        label: Text(_pdfController.isPopupOpen ? 'Close Popup' : 'Pop Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pdfController.isPopupOpen ? Colors.red[100] : Colors.green[100],
                          foregroundColor: _pdfController.isPopupOpen ? Colors.red[700] : Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Page Break Information:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Breaks: ${_pdfController.pageBreaksCount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _pdfController.hasPageBreaks 
                                    ? _pdfController.getPageBreaksAsJson()
                                    : 'No page breaks detected yet.',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Panel - PDF Preview
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PDF Preview:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PdfPaginatorWidget(
                      controller: _pdfController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Widget Controller Features:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Zoom: ${(_pdfController.zoomLevel * 100).round()}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Popup: ${_pdfController.isPopupOpen ? "Open" : "Closed"}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Page Breaks: ${_pdfController.pageBreaksCount}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Use the controls here to update content and zoom',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}