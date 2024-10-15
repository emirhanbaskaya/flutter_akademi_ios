import 'package:flutter/material.dart';
import 'question_display.dart';
import 'database_service.dart';

class DifficultySelectionModal extends StatefulWidget {
  final Map<String, dynamic> module;
  final DatabaseService dbService;

  DifficultySelectionModal({required this.module, required this.dbService});

  @override
  _DifficultySelectionModalState createState() => _DifficultySelectionModalState();
}

class _DifficultySelectionModalState extends State<DifficultySelectionModal> {
  String _selectedDifficulty = 'Easy';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Difficulty',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            value: _selectedDifficulty,
            items: <String>['Easy', 'Medium', 'Hard'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDifficulty = newValue!;
              });
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDisplayScreen(
                    pdfPath: widget.module['pdfPath'],
                    difficulty: _selectedDifficulty,
                    numberOfQuestions: widget.module['questionCount'],
                    name: widget.module['name'],
                    moduleId: widget.module['id'],
                    dbService: widget.dbService,
                  ),
                ),
              );
            },
            child: Text('Retake Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}