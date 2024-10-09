import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart'; // PDFx paketi dahil edildi
import 'question_setup.dart';

class PDFViewScreen extends StatefulWidget {
  final String pdfPath;

  PDFViewScreen({required this.pdfPath});

  @override
  _PDFViewScreenState createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  late PdfController _pdfController; // PDFx kontrolcüsü
  int _pages = 0;
  int _currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String detailedError = '';

  @override
  void initState() {
    super.initState();
    _loadPDF(); // PDF dosyasını yükle
  }

  // PDF yükleme fonksiyonu
  Future<void> _loadPDF() async {
    try {
      // PDFx kontrolcüsünü başlat
      _pdfController = PdfController(
        document: PdfDocument.openFile(widget.pdfPath),
        initialPage: _currentPage,
      );
      _loadTotalPages(); // Toplam sayfa sayısını yükle
    } catch (error) {
      setState(() {
        errorMessage = 'PDF dosyası yüklenirken bir hata oluştu.';
        detailedError = error.toString();
      });
    }
  }

  // Toplam sayfa sayısını öğrenme fonksiyonu
  Future<void> _loadTotalPages() async {
    try {
      final document = await PdfDocument.openFile(widget.pdfPath);
      setState(() {
        _pages = document.pagesCount;
        isReady = true;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'PDF sayfa sayısı alınamadı.';
        detailedError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar'ı kaldırarak tam ekran görünüm sağlıyoruz
      body: Stack(
        children: <Widget>[
          if (isReady)
            PdfView(
              controller: _pdfController,
              scrollDirection: Axis.vertical, // Dikey kaydırma için ayar
              onDocumentLoaded: (document) {
                setState(() {
                  _pages = document.pagesCount;
                });
              },
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          if (!isReady && errorMessage.isEmpty)
            Center(child: CircularProgressIndicator()),
          if (errorMessage.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    detailedError,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (errorMessage.isEmpty && isReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_upward, color: Colors.white),
            onPressed: () {
              if (_currentPage > 0) {
                _pdfController.previousPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            onPressed: () {
              if (_currentPage < _pages - 1) {
                _pdfController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.question_answer, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionSetupScreen(pdfPath: widget.pdfPath),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PageSelectorDialog extends StatelessWidget {
  final int pages;

  PageSelectorDialog({required this.pages});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Page'),
            SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pages,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${index + 1}'),
                    onTap: () {
                      Navigator.of(context).pop(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
