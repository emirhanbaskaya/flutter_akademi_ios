import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }

    if (!_isValidUsername(username)) {
      _showSnackBar('Username can only contain lowercase letters, numbers, and underscores');
      return;
    }

    if (username.contains(' ')) {
      _showSnackBar('Username must be written as one word');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user info to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
      });

      // Initialize DatabaseService (if needed)
      final dbService = DatabaseService(uid: userCredential.user!.uid);

      // Show success message
      _showSnackBar('Account created successfully');

      // Optionally, you can clear the input fields
      _emailController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed: ${e.message}';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already exists';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password should be at least 6 characters';
      }
      _showSnackBar(errorMessage);
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      // Handle other errors
      String errorMessage = 'An unexpected error occurred: $e';
      _showSnackBar(errorMessage);
      print('Exception: $e');
    } finally {
      // Ensure the loading indicator is dismissed
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-z0-9_]+$').hasMatch(username);
  }

  void _showSnackBar(String message) {
    print('Showing SnackBar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              _buildTextField(_emailController, 'Email'),
              SizedBox(height: 16),
              _buildTextField(_usernameController, 'Username'),
              SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : _buildElevatedButton('Register', _register),
              _buildTextButton('Back to Login', () => Navigator.pop(context)),
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
        style: TextStyle(color: Colors.tealAccent, fontStyle: FontStyle.italic),
      ),
    );
  }
}
