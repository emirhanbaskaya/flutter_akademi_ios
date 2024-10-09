import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class PDFTextExtractor {
  static Future<String> extractText(String pdfPath) async {
    final PdfDocument document = PdfDocument(inputBytes: File(pdfPath).readAsBytesSync());
    String extractedText = '';
    int characterLimit = 16385;

    // Belgedeki tüm sayfaları gez
    for (int i = 0; i < document.pages.count; i++) {
      // Sayfa sayfa metni çıkar
      String pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);

      // Karakter sınırına ulaşana kadar metni biriktir
      if (extractedText.length + pageText.length <= characterLimit) {
        extractedText += pageText;
      } else {
        // Karakter sınırına ulaşılırsa fazla kısmı kırp
        extractedText += pageText.substring(0, characterLimit - extractedText.length);
        break;
      }
    }

    return extractedText;
  }
}
