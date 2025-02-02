
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';

// class UserProfileScreen extends StatefulWidget {
//   const UserProfileScreen({super.key});

//   @override
//   _UserProfileScreenState createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends State<UserProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

//   final TextEditingController _nameController = TextEditingController();
//   String _gender = 'Male'; // Default gender
//   String _photoUrl = ''; // Photo URL
//   bool _isLoading = true;

//   final ImagePicker _picker = ImagePicker();

//   List<Map<dynamic, dynamic>> _userPosts = []; // Store user posts

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//     _fetchUserPosts(); // Fetch user's posts
//   }

//   // Fetch user details from Firebase Realtime Database
//   Future<void> _fetchUserDetails() async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         final snapshot = await _databaseRef.child('users/${user.uid}').get();

//         if (snapshot.exists) {
//           final data = snapshot.value as Map<dynamic, dynamic>;
//           setState(() {
//             _nameController.text = data['name'] ?? '';
//             _gender = data['gender'] ?? 'Male';
//             _photoUrl = data['photoUrl'] ?? '';
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching user details: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Fetch user posts from Firebase Realtime Database
//   Future<void> _fetchUserPosts() async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         final snapshot = await _databaseRef.child('posts').orderByChild('userId').equalTo(user.uid).get();

//         if (snapshot.exists) {
//           final postsData = snapshot.value as Map<dynamic, dynamic>;
//           setState(() {
//             _userPosts = postsData.values.map((e) => e as Map<dynamic, dynamic>).toList();
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching user posts: $e');
//     }
//   }

//   // Save updated user details to Firebase
//   Future<void> _saveUserDetails() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         await _databaseRef.child('users/${user.uid}').update({
//           'name': _nameController.text,
//           'gender': _gender,
//           'photoUrl': _photoUrl,
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//       }
//     } catch (e) {
//       print('Error saving user details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update profile')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Pick an image from camera or gallery
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _photoUrl = pickedFile.path; // Temporarily storing local path
//       });
//     }
//   }

//   // Show dialog for image selection
//   void _showImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Take a photo'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Choose from gallery'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Sign out the user
//   Future<void> _signOut() async {
//     try {
//       await _auth.signOut();
//       Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen
//     } catch (e) {
//       print('Error signing out: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to sign out')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: _showImagePickerOptions,
//                     child: _photoUrl.isEmpty
//                         ? const CircleAvatar(
//                             radius: 50,
//                             child: Icon(Icons.camera_alt, size: 50),
//                           )
//                         : CircleAvatar(
//                             radius: 50,
//                             backgroundImage: FileImage(File(_photoUrl)),
//                           ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(labelText: 'Name'),
//                   ),
//                   DropdownButton<String>(
//                     value: _gender,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _gender = newValue!;
//                       });
//                     },
//                     items: <String>['Male', 'Female', 'Other']
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _saveUserDetails,
//                     child: const Text('Save Changes'),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _signOut,
//                     child: const Text('Sign Out'),
//                   ),
//                   const Divider(),
//                   const Text(
//                     'My Posts',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   _userPosts.isEmpty
//                       ? const Text('No posts yet.')
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: _userPosts.length,
//                           itemBuilder: (context, index) {
//                             final post = _userPosts[index];
//                             return Card(
//                               child: ListTile(
//                                 title: Text(post['postText'] ?? 'Untitled'),
//                                 subtitle: Text(post['content'] ?? 'No content'),
//                               ),
//                             );
//                           },
//                         ),
//                 ],
//               ),
//             ),
//     );
//   }
// }





import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  final TextEditingController _nameController = TextEditingController();
  String _gender = 'Male'; // Default gender
  String _photoUrl = ''; // Photo URL
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();

  List<Map<dynamic, dynamic>> _userPosts = []; // Store user posts

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchUserPosts(); // Fetch user's posts
  }

  // Fetch user details from Firebase Realtime Database
  Future<void> _fetchUserDetails() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _databaseRef.child('users/${user.uid}').get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _gender = data['gender'] ?? 'Male';
            _photoUrl = data['photoUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch user posts from Firebase Realtime Database
  Future<void> _fetchUserPosts() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _databaseRef.child('posts').orderByChild('userId').equalTo(user.uid).get();

        if (snapshot.exists) {
          final postsData = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _userPosts = postsData.values.map((e) => e as Map<dynamic, dynamic>).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }

  // Save updated user details to Firebase
  Future<void> _saveUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _databaseRef.child('users/${user.uid}').update({
          'name': _nameController.text,
          'gender': _gender,
          'photoUrl': _photoUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print('Error saving user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _photoUrl = pickedFile.path; // Temporarily storing local path
      });
    }
  }

  // Show dialog for image selection
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
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Sign out the user
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        // backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: _photoUrl.isEmpty
                          ? const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.camera_alt, size: 40),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(File(_photoUrl)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InputDecorator(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0), // Reduced vertical padding
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButton<String>(
                      value: _gender,
                      onChanged: (String? newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: <String>['Male', 'Female', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _saveUserDetails,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _signOut,
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const Divider(height: 40),
                  const Text(
                    'My Posts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _userPosts.isEmpty
                      ? const Center(child: Text('No posts yet.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _userPosts.length,
                          itemBuilder: (context, index) {
                            final post = _userPosts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                title: Text(post['postText'] ?? 'Untitled'),
                                subtitle: Text(post['content'] ?? 'No content'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}