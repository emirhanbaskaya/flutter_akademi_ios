import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_selector/file_selector.dart';
import 'pdf_view.dart'; // pdf_view.dart dosyasını içe aktar
import 'database.dart'; // Veritabanı yardımıcı sınıfı içe aktar
import 'question_display.dart'; // QuestionDisplayScreen'i içe aktar

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Global olarak Roboto yazı tipini kullanın
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> modules = [];
  final List<Color> colors = [Colors.green, Colors.blue, Colors.red, Colors.orange, Colors.purple];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final data = await DatabaseHelper().queryAllModules();
    setState(() {
      modules = data;
    });
  }

  Future<void> _pickPDF() async {
    final typeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: ['pdf'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewScreen(pdfPath: file.path),
        ),
      ).then((_) => _loadModules());
    }
  }

  void _showEditDeleteOptions(Map<String, dynamic> module) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Delete Modal',
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.topCenter,
          child: EditDeleteModal(
            module: module,
            onModuleUpdated: _loadModules,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void _showDifficultySelection(Map<String, dynamic> module) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DifficultySelectionModal(
          module: module,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'PDF Uygulaması',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      _showDifficultySelection(module);
                    },
                    onLongPress: () {
                      _showEditDeleteOptions(module);
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            module['name'],
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap to retake the quiz.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _pickPDF,
                child: Text('Select PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditDeleteModal extends StatefulWidget {
  final Map<String, dynamic> module;
  final VoidCallback onModuleUpdated;

  EditDeleteModal({required this.module, required this.onModuleUpdated});

  @override
  _EditDeleteModalState createState() => _EditDeleteModalState();
}

class _EditDeleteModalState extends State<EditDeleteModal> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.module['name'];
  }

  Future<void> _updateModule() async {
    final updatedModule = {
      'id': widget.module['id'],
      'name': _nameController.text,
      'difficulty': widget.module['difficulty'],
      'questionCount': widget.module['questionCount'],
      'pdfPath': widget.module['pdfPath'],
    };
    await DatabaseHelper().updateModule(updatedModule);
    widget.onModuleUpdated();
    Navigator.pop(context);
  }

  Future<void> _deleteModule() async {
    await DatabaseHelper().deleteModule(widget.module['id']);
    widget.onModuleUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit or Delete Module',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Module Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateModule,
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _deleteModule,
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySelectionModal extends StatefulWidget {
  final Map<String, dynamic> module;

  DifficultySelectionModal({required this.module});

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
