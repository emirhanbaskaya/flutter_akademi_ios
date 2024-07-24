import 'package:flutter/material.dart';

class QuestionDisplayPage extends StatefulWidget {
  final List<String> questions;

  QuestionDisplayPage({required this.questions});

  @override
  _QuestionDisplayPageState createState() => _QuestionDisplayPageState();
}

class _QuestionDisplayPageState extends State<QuestionDisplayPage> {
  final Map<int, String> answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sorular'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.questions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soru ${index + 1}: ${widget.questions[index]}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            answers[index] = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Cevap',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}