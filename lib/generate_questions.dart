import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pdf_text.dart';

class QuestionGenerator {
  final String pdfPath;
  final int numberOfQuestions;

  QuestionGenerator({required this.pdfPath, required this.numberOfQuestions});

  Future<List<Map<String, dynamic>>> generateQuestions() async {
    final String apiUrl = dotenv.env['OPENAI_API_URL'] ?? '';
    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    print('API URL: $apiUrl');
    print('API Key: $apiKey');

    if (apiUrl.isEmpty || apiKey.isEmpty) {
      print('API URL or API Key is not set.');
      return [];
    }

    final String text = await PDFTextExtractor.extractText(pdfPath);

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
              'content': 'Generate $numberOfQuestions multiple choice questions and their options from the following text. For each question, include one correct answer and three incorrect answers without labeling them as correct or incorrect.'
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
        final List<Map<String, dynamic>> questions = [];
        final content = data['choices'][0]['message']['content'].toString();
        final questionBlocks = content.split('\n\n');

        for (var block in questionBlocks) {
          final lines = block.split('\n');
          final question = lines[0];
          final options = lines.skip(1).map((line) {
            final isCorrect = line.contains('(correct)');
            final optionText = line.replaceFirst(RegExp(r'\s*\(correct\)\s*'), '');
            return {
              'option': optionText,
              'isCorrect': isCorrect
            };
          }).toList();

          final correctAnswer = options.firstWhere(
                  (option) => option['isCorrect'] == true,
              orElse: () => {'option': 'No correct answer found'}
          )['option'];

          questions.add({
            'question': question,
            'options': options.map((option) => option['option']).toList(),
            'correctAnswer': correctAnswer,
          });
        }

        return questions;
      } else {
        print('Failed to generate questions. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error during API call: $e');
      return [];
    }
  }
}