import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class PDFTextExtractor {
  static Future<String> extractText(String pdfPath) async {
    final PdfDocument document = PdfDocument(inputBytes: File(pdfPath).readAsBytesSync());
    return PdfTextExtractor(document).extractText();
  }
}
