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
        title: Text('Setup Questions'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Klavye açıldığında alan ayırmak için
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setup Your Quiz',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Difficulty',
                style: TextStyle(fontSize: 18.0),
              ),
              DropdownButton<String>(
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
              ),
              SizedBox(height: 16.0),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _generateQuestions,
                child: Text('Generate Questions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Quiz Settings',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.question_answer),
                title: Text('10 Questions'),
              ),
              ListTile(
                leading: Icon(Icons.sort),
                title: Text('Easy, Medium, Hard'),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Your Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
