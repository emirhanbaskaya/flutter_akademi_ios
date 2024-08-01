import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'pdf_viewer_page.dart';
import 'pdf_model.dart';
import 'pdf_database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Soru Oluşturucu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PdfModel> pdfModules = [];

  @override
  void initState() {
    super.initState();
    _loadPdfModules();
  }

  _loadPdfModules() async {
    pdfModules = await PdfDatabase.instance.readAllPdfs();
    setState(() {});
  }

  _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(file: file),
        ),
      ).then((value) => _loadPdfModules());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Soru Oluşturucu'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPdfModules,
          ),
        ],
      ),
      body: pdfModules.isEmpty
          ? Center(
        child: Text('Henüz bir modül oluşturulmadı.'),
      )
          : ListView.builder(
        itemCount: pdfModules.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(pdfModules[index].name),
            onTap: () {
              // Modül detay sayfasına yönlendir
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickPdf,
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 83, 101, 116),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}