import 'package:flutter/material.dart';
import 'question_display.dart';
import 'generate_questions.dart';
import 'database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionSetupScreen extends StatefulWidget {
  final String pdfPath;

  QuestionSetupScreen({required this.pdfPath});

  @override
  _QuestionSetupScreenState createState() => _QuestionSetupScreenState();
}

class _QuestionSetupScreenState extends State<QuestionSetupScreen> {
  String _difficulty = 'Easy';
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = true;

  late DatabaseService dbService;
  late String moduleId;
  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    dbService = DatabaseService(uid: uid);
  }

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

    // Show the loading dialog while questions are being generated
    _showLoadingDialog();

    try {
      Map<String, dynamic> moduleData = {
        'name': _nameController.text,
        'difficulty': _difficulty,
        'questionCount': 10,
        'pdfPath': widget.pdfPath,
      };
      moduleId = await dbService.insertModule(moduleData);
      QuestionGenerator generator = QuestionGenerator(
        pdfPath: widget.pdfPath,
        numberOfQuestions: 10,
        difficulty: _difficulty,
        moduleId: moduleId,
        dbService: dbService,
      );
      List<Map<String, dynamic>> generatedQuestions = await generator.generateQuestions();


      Navigator.pop(context);


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionDisplayScreen(
            pdfPath: widget.pdfPath,
            difficulty: _difficulty,
            numberOfQuestions: 10,
            name: _nameController.text,
            moduleId: moduleId,
            dbService: dbService,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      // Optionally show an error dialog
      _showErrorDialog();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents the user from dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Please wait',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 20.0, // Slightly larger font
              ),
            ),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.0),
              Expanded(
                child: Text(
                  'Your questions are being generated...',
                  style: TextStyle(
                    color: Colors.teal, // Text color is teal
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.teal), // Text color is teal
          ),
          content: Text(
            'An error occurred while generating the questions.',
            style: TextStyle(color: Colors.black), // Text color is teal
          ),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Difficulty',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
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
            SizedBox(height: 24.0),
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
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _generateQuestions,
                child: Text(
                  'Generate Questions',
                  style: TextStyle(color: Colors.white),
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
            Spacer(),
          ],
        ),
      ),
    );
  }
}
