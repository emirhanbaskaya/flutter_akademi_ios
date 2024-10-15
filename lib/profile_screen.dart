import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  String _username = '';
  String _profilePictureUrl = '';
  int _userPoints = 0;
  bool _isLoading = true;
  File? _profileImageFile;

  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user profile data from Firestore
  Future<void> _loadUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? '';
          _profilePictureUrl = userDoc['profilePictureUrl'] ?? '';
          _userPoints = userDoc['points'] ?? 0;
          _usernameController.text = _username;
          _isLoading = false;
        });
      }
    }
  }

  // Open the image picker to allow the user to upload a profile picture
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedFile != null) {
      // Allow the user to crop the image
      File? croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _profileImageFile = croppedFile;
        });
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.teal,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Save profile changes
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      String? profilePictureUrl = _profilePictureUrl;

      // Upload new profile picture if selected
      if (_profileImageFile != null) {
        try {
          Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');

          UploadTask uploadTask = storageRef.putFile(_profileImageFile!);

          TaskSnapshot snapshot = await uploadTask;

          profilePictureUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          print('Error uploading profile picture: $e');
        }
      }

      // Update user data in Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'username': _usernameController.text.trim(),
          'profilePictureUrl': profilePictureUrl,
        });

        setState(() {
          _username = _usernameController.text.trim();
          _profilePictureUrl = profilePictureUrl ?? '';
          _isEditing = false; // Exit edit mode
          _profileImageFile = null;
          _isLoading = false;
        });
      } catch (e) {
        print('Error updating profile: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isEditing
          ? AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.check), // Save button in edit mode
            onPressed: _saveProfile,
          ),
        ],
        backgroundColor: Colors.teal,
      )
          : AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : (_profilePictureUrl.isNotEmpty
                      ? NetworkImage(_profilePictureUrl)
                      : null) as ImageProvider?,
                  child: (_profilePictureUrl.isEmpty &&
                      _profileImageFile == null)
                      ? Icon(Icons.person,
                      size: 60, color: Colors.teal)
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.teal),
                      onPressed: _pickProfileImage,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            _isEditing
                ? TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Update Username',
                border: OutlineInputBorder(),
              ),
            )
                : Text(
              _username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 8.0),
            if (!_isEditing)
              ElevatedButton.icon(
                onPressed: _toggleEditMode,
                icon: Icon(Icons.edit,
                    size: 18, color: Colors.white),
                label: Text('Edit Profile',
                    style: TextStyle(
                        fontSize: 14.0, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            SizedBox(height: 32.0),
            Spacer(),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your Points',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      '$_userPoints',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
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
