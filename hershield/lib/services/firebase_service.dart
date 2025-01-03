import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:hershield/services/fcmToken_service.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Update the user's location in Realtime Database
  Future<void> updateUserLocation(String userId, double latitude, double longitude) async {
    try {
      String? token = await saveTokenToDatabase();
      await _database.child('users').child(userId).update({
      'latitude': latitude,
      'longitude': longitude,
      'fcmToken': token,
      'timestamp': DateTime.now().toIso8601String(),
    });
          
      print("User location updated successfully.");
    } catch (e) {
      print("Error updating user location: $e");
    }
  }


  // Haversine Formula to calculate distance between two lat/long points in meters
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the Earth in meters
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Fetch users within a radius
  Future<List<Map<String, dynamic>>> getUsersWithinRadius(
    double currentLat, double currentLon, double radiusInMeters) async {
    List<Map<String, dynamic>> nearbyUsers = [];

    try {
      final snapshot = await _database.child('users').get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

        users.forEach((key, value) {
          double userLat = value['latitude'];
          double userLon = value['longitude'];

          // Calculate distance from current user
          double distance =
              calculateDistance(currentLat, currentLon, userLat, userLon);

          // Add user to the list if within radius
          if (distance <= radiusInMeters) {
            nearbyUsers.add({
              'userId': key,
              'latitude': userLat,
              'longitude': userLon,
              'distance': distance,
            });
          }
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }

    return nearbyUsers;
  }
}