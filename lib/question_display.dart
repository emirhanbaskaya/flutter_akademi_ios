import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pdf_text.dart';

class QuestionDisplayScreen extends StatefulWidget {
  final String pdfPath;
  final String difficulty;
  final int numberOfQuestions;
  final String name;

  QuestionDisplayScreen({
    required this.pdfPath,
    required this.difficulty,
    required this.numberOfQuestions,
    required this.name,
  });

  @override
  _QuestionDisplayScreenState createState() => _QuestionDisplayScreenState();
}

class _QuestionDisplayScreenState extends State<QuestionDisplayScreen> {
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  List<String?> _selectedAnswers = List<String?>.filled(0, null);

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  Future<void> _generateQuestions() async {
    final String apiUrl = dotenv.env['OPENAI_API_URL'] ?? '';
    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    print('API URL: $apiUrl');
    print('API Key: $apiKey');

    if (apiUrl.isEmpty || apiKey.isEmpty) {
      print('API URL or API Key is not set.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String text = await PDFTextExtractor.extractText(widget.pdfPath);

    print('Extracted Text: $text');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Generate ${widget.numberOfQuestions} multiple choice questions and their options from the following text. Provide correct answers as well.'
            },
            {
              'role': 'user',
              'content': text
            }
          ],
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data['choices'].map((choice) {
            final content = choice['message']['content'].toString();
            final parts = content.split('\n');
            final question = parts[0];
            final options = parts.skip(1).where((part) => part.isNotEmpty && !part.startsWith('*')).map((option) {
              final optionText = option.replaceFirst(RegExp(r'^[a-d]\.\s+'), ''); // Seçenek başındaki harfi ve boşluğu kaldırır
              return optionText;
            }).toList();
            return {
              'question': question,
              'options': options,
            };
          }));
          _selectedAnswers = List<String?>.filled(questions.length, null);
          isLoading = false;
        });
      } else {
        print('Failed to generate questions. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error during API call: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectAnswer(String? answer, int index) {
    setState(() {
      _selectedAnswers[index] = answer;
    });
  }

  void _submitQuiz() {
    int correctAnswersCount = 0;
    // Bu kısımda doğru cevap sayısını kontrol etmek için doğru cevapların saklandığı başka bir yöntem kullanmalısınız.
    // Şu anda doğru cevaplar elimizde olmadığı için her zaman 0 dönecektir.
    _showScoreDialog(correctAnswersCount);
  }

  void _showScoreDialog(int correctAnswersCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Result'),
        content: Text('You got $correctAnswersCount out of ${questions.length} correct.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to the previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Multiple Choice Questions"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0), // Sorular arasında boşluk
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${question['question']}',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        ...question['options'].map<Widget>((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _selectedAnswers[index],
                            onChanged: (value) {
                              _selectAnswer(value, index);
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _submitQuiz,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
