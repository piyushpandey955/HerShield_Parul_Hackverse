import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hershield/home_screen.dart';
import 'package:image_picker/image_picker.dart'; // For picking an image
import '../services/profile_service.dart'; // Import the ProfileService file

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _gender = 'Male'; // Default gender
  String _photoUrl = ''; // Store the photo URL
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _photoUrl = pickedFile.path; // Save the local file path for now
      });
    }
  }

  // Show dialog to select between Camera and Gallery
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera); // Pick image from camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery); // Pick image from gallery
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to save the profile data
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ProfileService().saveProfileData(
        _nameController.text,
        _gender,
        _photoUrl,
      );

      // Navigate to home screen after saving profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            DropdownButton<String>(
              value: _gender,
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
              items: <String>['Male', 'Female', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showImagePickerOptions, // Show options for camera/gallery
              child: _photoUrl.isEmpty
                  ? const CircleAvatar(radius: 40, child: Icon(Icons.camera_alt))
                  : CircleAvatar(radius: 40, backgroundImage: FileImage(File(_photoUrl))),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
          ],
        ),
      ),
    );
  }
}