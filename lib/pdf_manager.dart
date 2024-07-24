import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'pdf_viewer_page.dart';
import 'pdf_database.dart';
import 'pdf_model.dart';

class PdfManager extends StatefulWidget {
  @override
  _PdfManagerState createState() => _PdfManagerState();
}

class _PdfManagerState extends State<PdfManager> {
  late Future<List<PdfModel>> pdfs;

  @override
  void initState() {
    super.initState();
    pdfs = PdfDatabase.instance.readAllPdfs();
  }

  Future<void> _pickPdf(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(file: file),
        ),
      ).then((value) {
        setState(() {
          pdfs = PdfDatabase.instance.readAllPdfs();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Yönetici'),
      ),
      body: FutureBuilder<List<PdfModel>>(
        future: pdfs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz PDF yok'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pdf = snapshot.data![index];
                return ListTile(
                  title: Text(pdf.name),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewerPage(file: File(pdf.path)),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await PdfDatabase.instance.delete(pdf.id!);
                      setState(() {
                        pdfs = PdfDatabase.instance.readAllPdfs();
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickPdf(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
