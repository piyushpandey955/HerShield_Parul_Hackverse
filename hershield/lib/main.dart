// import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hershield/services/notification_service.dart';
// import 'wrapper.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// //handling bg notifs
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling background message: ${message.messageId}");
// }
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); //to initialise firebase 
//   await dotenv.load(); //to load .env file
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); //to handle bg notif
//   NotificationService.initializeNotifClickingOnscreenWhenReceived(); //to initialse notif service
//   FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: true);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//         debugShowCheckedModeBanner: false, home: Wrapper());
//   }
// }


import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'wrapper.dart'; // Wrapper for determining the initial screen

// Handling background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await dotenv.load(); // Load environment variables from .env file
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // Handle background notifications
  NotificationService.initializeNotifClickingOnscreenWhenReceived(); // Initialize custom notification service
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  ); // Configure notification presentation options

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Wrapper(), // Wrapper to decide the initial screen
    );
  }
}
