import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'pdf_view.dart'; // pdf_view.dart dosyasını içe aktar
import 'question_display.dart'; // question_display.dart dosyasını içe aktar
import 'database.dart'; // Veritabanı yardımıcı sınıfı içe aktar

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final data = await DatabaseHelper().queryAllModules();
    setState(() {
      modules = data;
    });
  }

  Future<void> _pickPDF() async {
    final typeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: ['pdf'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewScreen(pdfPath: file.path),
        ),
      ).then((_) => _loadModules());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Uygulaması'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return ListTile(
                  title: Text(module['name']),
                  subtitle: Text('Difficulty: ${module['difficulty']} - Questions: ${module['questionCount']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionDisplayScreen(
                          pdfPath: module['pdfPath'], // Veritabanından modül bilgileriyle PDF dosya yolunu ayarlayın
                          difficulty: module['difficulty'],
                          numberOfQuestions: module['questionCount'],
                          name: module['name'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _pickPDF,
                child: Text('PDF Seç'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
