import 'package:flutter/material.dart';
import 'dart:io';
import 'question_display_page.dart';

class ModuleSettingsPage extends StatefulWidget {
  final File file;

  ModuleSettingsPage({required this.file});

  @override
  _ModuleSettingsPageState createState() => _ModuleSettingsPageState();
}

class _ModuleSettingsPageState extends State<ModuleSettingsPage> {
  final TextEditingController _moduleNameController = TextEditingController();
  final TextEditingController _numQuestionsController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final List<String> questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modül Ayarları'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _moduleNameController,
              decoration: InputDecoration(
                labelText: 'Modül İsmi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _numQuestionsController,
              decoration: InputDecoration(
                labelText: 'Soru Sayısı',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _difficultyController,
              decoration: InputDecoration(
                labelText: 'Zorluk Seviyesi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                int numQuestions = int.tryParse(_numQuestionsController.text) ?? 0;
                for (int i = 0; i < numQuestions; i++) {
                  questions.add('Bu, soru ${i + 1}');
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuestionDisplayPage(questions: questions),
                  ),
                );
              },
              child: Text('Soruları Göster'),
            ),
          ],
        ),
      ),
    );
  }
}