import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Save profile data to Firebase
  Future<void> saveProfileData(String name, String gender, String photoUrl) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final userId = user.uid;

        // Profile data to be saved
        Map<String, String> userProfile = {
          'name': name,
          'gender': gender,
          'photoUrl': photoUrl,
        };

        // Save to Firebase Realtime Database using ref()
        await _database.ref().child('users').child(userId).set(userProfile);

        print('Profile saved successfully!');
      } catch (e) {
        print('Error saving profile: $e');
      }
    }
  }

  // Check if the user's profile exists and load it
  Future<Map<String, String>?> getProfileData() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final snapshot = await _database.ref().child('users').child(user.uid).get();

        // Check if data exists
        if (snapshot.value != null) {
          // Safely cast to Map
          Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from(snapshot.value as Map);

          return {
            'name': userData['name'],
            'gender': userData['gender'],
            'photoUrl': userData['photoUrl'],
          };
        } else {
          return null;  // No profile data found
        }
      } catch (e) {
        print('Error loading profile: $e');
        return null;
      }
    }
    return null;  // User not logged in
  }
}