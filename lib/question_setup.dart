import 'package:flutter/material.dart';
import 'question_display.dart';

class QuestionSetupScreen extends StatefulWidget {
  final String pdfPath;

  QuestionSetupScreen({required this.pdfPath});

  @override
  _QuestionSetupScreenState createState() => _QuestionSetupScreenState();
}

class _QuestionSetupScreenState extends State<QuestionSetupScreen> {
  int _numQuestions = 1;
  String _difficulty = 'Easy';
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Difficulty'),
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
            SizedBox(height: 16),
            Text('Number of Questions'),
            Slider(
              value: _numQuestions.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _numQuestions.toString(),
              onChanged: (double value) {
                setState(() {
                  _numQuestions = value.toInt();
                });
              },
            ),
            SizedBox(height: 16),
            Text('Name'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionDisplayScreen(
                        pdfPath: widget.pdfPath,
                        difficulty: _difficulty,
                        numberOfQuestions: _numQuestions,
                        name: _nameController.text,
                      ),
                    ),
                  );
                },
                child: Text('Generate Questions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
