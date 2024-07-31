import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_selector/file_selector.dart';
import 'pdf_view.dart';  // pdf_view.dart dosyasını içe aktar
import 'question_display.dart'; // question_display.dart dosyasını içe aktar
import 'database.dart'; // Veritabanı yardımıcı sınıfı içe aktar
import 'login_screen.dart'; // Login ekranı içe aktar

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await DatabaseHelper().deleteDatabase(); // Veritabanını sil
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug etiketini kaldır
      title: 'PDF Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Giriş ekranına yönlendir
    );
  }
}
