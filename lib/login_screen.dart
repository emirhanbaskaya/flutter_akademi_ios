import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';
import 'main.dart'; // HomeScreen import
import 'register_screen.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      // Kullanıcı giriş işlemi
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);

      final dbService = DatabaseService(uid: userCredential.user!.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(dbService: dbService),
        ),
      );

    } catch (e) {
      _showSnackBar('Geçersiz email ya da şifre');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EduQuest',
                style: _textStyle(Colors.teal, 28.0, FontWeight.bold),
              ),
              SizedBox(height: 50),
              _buildTextField(_usernameController, 'Email'),
              SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text(
                  "Beni hatırla",
                  style: TextStyle(color: Colors.white),
                ),
                value: _rememberMe,
                onChanged: (newValue) {
                  setState(() {
                    _rememberMe = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.teal,
              ),
              SizedBox(height: 20),
              _buildElevatedButton('Giriş Yap', _login),
              _buildTextButton('Hesabınız yok mu? Kayıt olun', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(fontSize: 14, color: Colors.white),
      obscureText: obscureText,
    );
  }

  TextStyle _textStyle(Color color, double fontSize, FontWeight fontWeight) {
    return TextStyle(
      fontFamily: 'Roboto',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.tealAccent,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
