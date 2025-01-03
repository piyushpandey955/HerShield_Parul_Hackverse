import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future<String?> getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  return token;
}

Future<String?> saveTokenToDatabase() async {
  // Fetch the current user's UID
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String uid = user.uid;

    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      // Reference to Realtime Database
      DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

      // Save the token in the user's node
      await databaseRef.child('users/$uid/fcmToken').set(token);

      print("FCM Token saved to database: $token");
      return token;
    }
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

        // Update the FCM token in the database
        await databaseRef.child('users/$uid/fcmToken').set(newToken);
        print("FCM Token updated: $newToken");
      }
    });
  return null;
}



