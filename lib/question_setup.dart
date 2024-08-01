import 'package:flutter/material.dart';
import 'question_display.dart'; // QuestionDisplayScreen'i import edin
import 'generate_questions.dart';
import 'database.dart';

class QuestionSetupScreen extends StatefulWidget {
  final String pdfPath; // pdfPath parametresi eklendi

  QuestionSetupScreen({required this.pdfPath});

  @override
  _QuestionSetupScreenState createState() => _QuestionSetupScreenState();
}

class _QuestionSetupScreenState extends State<QuestionSetupScreen> {
  String _difficulty = 'Easy';
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = true;

  Future<void> _generateQuestions() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameValid = false;
      });
      return;
    }

    setState(() {
      _isNameValid = true;
    });

    // Generate questions and navigate to the next screen
    QuestionGenerator generator = QuestionGenerator(
      pdfPath: widget.pdfPath, // pdfPath parametresi kullanıldı
      numberOfQuestions: 10,
    );
    List<Map<String, dynamic>> generatedQuestions = await generator.generateQuestions();
    await DatabaseHelper().insertModule({
      'name': _nameController.text,
      'difficulty': _difficulty,
      'questionCount': 10,
      'pdfPath': widget.pdfPath, // pdfPath parametresi kullanıldı
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDisplayScreen(
          pdfPath: widget.pdfPath, // pdfPath parametresi kullanıldı
          difficulty: _difficulty,
          numberOfQuestions: 10,
          name: _nameController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setup Questions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white), // Geri tuşunun rengini beyaz yapar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Difficulty',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center, // Metni ortalar
            ),
            SizedBox(height: 8.0), // Boşluk ekleme
            DropdownButtonFormField<String>(
              value: _difficulty,
              items: <String>['Easy', 'Medium', 'Hard'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _difficulty = newValue!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 24.0), // Boşluk ekleme
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                errorText: _isNameValid ? null : 'Name is required',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Spacer(), // Kalan boşluğu doldurur ve butonu en altına yerleştirir
            Center(
              child: ElevatedButton(
                onPressed: _generateQuestions,
                child: Text(
                  'Generate Questions',
                  style: TextStyle(color: Colors.white), // Metin rengini beyaz yapar
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  textStyle: TextStyle(fontSize: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            Spacer(), // Kalan boşluğu doldurur ve butonu en altına yerleştirir
          ],
        ),
      ),
    );
  }
}
