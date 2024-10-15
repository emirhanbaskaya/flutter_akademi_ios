import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String _currentUsername = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _emailController.text = user.email ?? '';
          _usernameController.text = userDoc['username'] ?? '';
          _currentUsername = userDoc['username'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _updateUsername() async {
    String newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      _showSnackBar('Username cannot be empty');
      return;
    }

    // Check if the username is already taken
    bool isUsernameTaken = await _isUsernameTaken(newUsername);
    if (isUsernameTaken) {
      _showSnackBar('Username already exists');
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'username': newUsername,
        });
        setState(() {
          _currentUsername = newUsername;
        });
        _showSnackBar('Username updated successfully');
      } catch (e) {
        _showSnackBar('Failed to update username');
      }
    }
  }

  Future<void> _updateEmail() async {
    String newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) {
      _showSnackBar('Email cannot be empty');
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(newEmail);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'email': newEmail,
        });
        _showSnackBar('Email updated successfully');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          _showSnackBar('Please re-authenticate to update email');
        } else if (e.code == 'email-already-in-use') {
          _showSnackBar('Email is already in use');
        } else {
          _showSnackBar('Failed to update email');
        }
      } catch (e) {
        _showSnackBar('An error occurred');
      }
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        _showSnackBar('Password updated successfully');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showSnackBar('Password should be at least 6 characters');
        } else if (e.code == 'requires-recent-login') {
          _showSnackBar('Please re-authenticate to update password');
        } else {
          _showSnackBar('Failed to update password');
        }
      } catch (e) {
        _showSnackBar('An error occurred');
      }
    }
  }

  Future<bool> _isUsernameTaken(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    setState(() {}); // Update UI to reflect theme change
    _showSnackBar('Settings saved');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(
              'Signed in as',
              style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              _currentUsername,
              style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black),
            ),
          ),
          Divider(color: _isDarkTheme ? Colors.grey : Colors.black),
          ListTile(
            title: Text(
              'Change Username',
              style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            onTap: _changeUsernameDialog,
          ),
          ListTile(
            title: Text(
              'Change Email',
              style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            onTap: _changeEmailDialog,
          ),
          ListTile(
            title: Text(
              'Change Password',
              style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            onTap: _changePasswordDialog,
          ),
          SwitchListTile(
            title: Text(
              'Dark Theme',
              style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            value: _isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                _isDarkTheme = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _changeUsernameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'New Username',
              labelStyle: TextStyle(color: Colors.grey),
            ),
            style:
            TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style:
                  TextStyle(color: _isDarkTheme ? Colors.white : Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change',
                  style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
                _updateUsername();
              },
            ),
          ],
          backgroundColor: _isDarkTheme ? Colors.grey[800] : Colors.white,
        );
      },
    );
  }

  void _changeEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Email'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'New Email',
              labelStyle: TextStyle(color: Colors.grey),
            ),
            style:
            TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style:
                  TextStyle(color: _isDarkTheme ? Colors.white : Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
                _updateEmail();
              },
            ),
          ],
          backgroundColor: _isDarkTheme ? Colors.grey[800] : Colors.white,
        );
      },
    );
  }

  void _changePasswordDialog() {
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
                style: TextStyle(
                    color: _isDarkTheme ? Colors.white : Colors.black),
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
                style: TextStyle(
                    color: _isDarkTheme ? Colors.white : Colors.black),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style:
                  TextStyle(color: _isDarkTheme ? Colors.white : Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                if (_newPasswordController.text ==
                    _confirmPasswordController.text) {
                  Navigator.of(context).pop();
                  _updatePassword(_newPasswordController.text);
                } else {
                  _showSnackBar('Passwords do not match');
                }
              },
            ),
          ],
          backgroundColor: _isDarkTheme ? Colors.grey[800] : Colors.white,
        );
      },
    );
  }
}
