import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hershield/services/firebase_service.dart';


//made object of FirebaseService class
final FirebaseService _firebaseService = FirebaseService();
final DatabaseReference _database = FirebaseDatabase.instance.ref();

// Function to fetch nearby users and send notifications
Future<List<String>> getNearbyUsersFCMTokens(
  double currentuserLat, double currentuserLng, double radiusInMeters) async {
  final nearbyUsersTokens = <String>[];
  
  try{
    final snapshot = await _database.child('users').get();

    if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

        users.forEach((key, value) {
          double userLat = value['latitude'];
          double userLon = value['longitude'];
          String token = value['fcmToken']??'';
          print(token);

          // Calculate distance from current user
          double distance =
              _firebaseService.calculateDistance(currentuserLat,currentuserLng,userLat,userLon);

          // Add user to the list if within radius
          if (distance <= radiusInMeters) {
            nearbyUsersTokens.add(
              token,
            );
          }
        });
      }

  } catch (e) {
      print("Error fetching tokens: $e");
    }

    return nearbyUsersTokens;
  }

// Function to send a single notification
Future<void> sendNotificationToNearbyUsers({
  required List<String> tokens,
  required String title,
  required String body,
  required double latitude,
  required double longitude,
}) async {
  const String fcmUrl = 'https://fcm.googleapis.com/v1/projects/hershield-605f6/messages:send';
  String serverKey = dotenv.env['FIREBASE_SERVER_KEY']!; // Replace with actual key

  for (final token in tokens) {
    if(token.isNotEmpty){
      final notificationPayload = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "alert_type": "panic",
          "latitude": latitude.toString(), // Include latitude
          "longitude": longitude.toString(), // Include longitude
        },
      }
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully to token: $token");
      } else {
        print("Failed to send notification to token $token: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification to token $token: $e");
    }
    }
    
  }
}