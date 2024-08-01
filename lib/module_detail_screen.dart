import 'dart:convert'; // dart:convert paketini ekle
import 'package:flutter/material.dart';
import 'generate_questions.dart';
import 'database.dart';
import 'question_display.dart'; // QuestionDisplayScreen'ı ekle

class ModuleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> module;

  ModuleDetailScreen({required this.module});

  @override
  _ModuleDetailScreenState createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _difficulty = 'Easy';
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.module['name'];
    _difficulty = widget.module['difficulty'];
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final data = await DatabaseHelper().queryQuestions(widget.module['id']);
    setState(() {
      questions = data;
    });
  }

  Future<void> _updateModule() async {
    final updatedModule = {
      'id': widget.module['id'],
      'name': _nameController.text,
      'difficulty': _difficulty,
      'questionCount': widget.module['questionCount'],
      'pdfPath': widget.module['pdfPath'],
    };
    await DatabaseHelper().updateModule(updatedModule);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Module updated successfully')),
    );
  }

  Future<void> _deleteModule() async {
    await DatabaseHelper().deleteModule(widget.module['id']);
    Navigator.pop(context);
  }

  Future<void> _generateNewQuestions() async {
    QuestionGenerator generator = QuestionGenerator(
      pdfPath: widget.module['pdfPath'],
      numberOfQuestions: widget.module['questionCount'],
    );
    List<Map<String, dynamic>> generatedQuestions = await generator.generateQuestions();
    await DatabaseHelper().deleteQuestions(widget.module['id']);
    for (var question in generatedQuestions) {
      await DatabaseHelper().insertQuestion({
        'moduleId': widget.module['id'],
        'question': question['question'],
        'correctAnswer': question['correctAnswer'],
        'options': jsonEncode(question['options']),
      });
    }
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module['name']),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Edit Module Name'),
                    content: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: 'Enter module name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _updateModule();
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'delete') {
                _deleteModule();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionDisplayScreen(
                          pdfPath: widget.module['pdfPath'],
                          difficulty: _difficulty,
                          numberOfQuestions: widget.module['questionCount'],
                          name: _nameController.text,
                        ),
                      ),
                    );
                  },
                  child: Text('Show Questions'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _generateNewQuestions,
                  child: Text('Generate New Questions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
