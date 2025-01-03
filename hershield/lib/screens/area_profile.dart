// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class AreaProfileScreen extends StatefulWidget {
//   final LatLng tappedLocation;

//   const AreaProfileScreen({super.key, required this.tappedLocation});

//   @override
//   _AreaProfileScreenState createState() => _AreaProfileScreenState();
// }

// class _AreaProfileScreenState extends State<AreaProfileScreen> {
//   int maleCount = 0;
//   int femaleCount = 0;
//   int threatPercentage = 0;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAreaDetails(widget.tappedLocation);
//   }

//   Future<void> _fetchAreaDetails(LatLng tappedLocation) async {
//     final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
//     // final DatabaseReference threatsRef = FirebaseDatabase.instance.ref('areaThreats');

//     try {
//       // Fetch all users
//       final usersSnapshot = await usersRef.get();

//       if (usersSnapshot.exists) {
//         final users = usersSnapshot.value as Map<dynamic, dynamic>;

//         int localMaleCount = 0;
//         int localFemaleCount = 0;

//         // Iterate through users to count based on gender
//         users.forEach((key, value) {
//           final double userLat = value['latitude'];
//           final double userLng = value['longitude'];
//           final String userGender = value['gender'];

//           if (_isWithinArea(userLat, userLng, tappedLocation)) {
//             if (userGender == 'Male') {
//               localMaleCount++;
//             } else if (userGender == 'Female') {
//               localFemaleCount++;
//             }
//           }
//         });

//         // // Fetch crime rate for the area
//         // final threatSnapshot = await threatsRef.child('areaId1').get();
//         // int localThreatPercentage = 0;

//         // if (threatSnapshot.exists) {
//         //   localThreatPercentage = threatSnapshot.value['crimePercentage'];
//         // }else {
//         //   // Calculate threat percentage if data is not available
//         //   // Calculate threat percentage dynamically
//         //   int calculateThreatPercentage(int males, int females) {
//         //     if (females == 0) return 0; // Avoid division by zero
//         //     return ((females / (males + females)) * 100).toInt();
//         //   }
//         //   final int localThreatPercentage = calculateThreatPercentage(localMaleCount, localFemaleCount);
//         // }

//       // Dynamically calculate threat percentage
//       final int localThreatPercentage = calculateThreatPercentage(localMaleCount, localFemaleCount);


//         // Update the state with the counts and percentage
//         setState(() {
//           maleCount = localMaleCount;
//           femaleCount = localFemaleCount;
//           threatPercentage = localThreatPercentage;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching area details: $e');
//     }
//   }

//   // Calculate threat percentage dynamically
//   int calculateThreatPercentage(int males, int females) {
//     if (females == 0) return 0; // Avoid division by zero
//     return ((females / (males + females)) * 100).toInt();
//   }

//   // Helper function to check if a user is within the tapped area
//   bool _isWithinArea(double userLat, double userLng, LatLng tappedLocation) {
//     const double areaRadius = 0.0001; // Define area radius (adjust as needed)
//     final double latDiff = (userLat - tappedLocation.latitude).abs();
//     final double lngDiff = (userLng - tappedLocation.longitude).abs();
//     return latDiff <= areaRadius && lngDiff <= areaRadius;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Area Profile')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Area Details',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Text('Males: $maleCount'),
//                   Text('Females: $femaleCount'),
//                   Text('Threat Percentage: $threatPercentage%'),
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AreaProfileScreen extends StatefulWidget {
  final LatLng tappedLocation;

  const AreaProfileScreen({super.key, required this.tappedLocation});

  @override
  _AreaProfileScreenState createState() => _AreaProfileScreenState();
}

class _AreaProfileScreenState extends State<AreaProfileScreen> {
  int maleCount = 0;
  int femaleCount = 0;
  int threatPercentage = 0;
  String cityName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAreaDetails(widget.tappedLocation);
  }

  Future<void> _fetchAreaDetails(LatLng tappedLocation) async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');

    try {
      // Fetch city name using reverse geocoding
      cityName = await _getCityName(tappedLocation);

      // Fetch all users within the area
      final usersSnapshot = await usersRef.get();

      if (usersSnapshot.exists) {
        final users = usersSnapshot.value as Map<dynamic, dynamic>;

        int localMaleCount = 0;
        int localFemaleCount = 0;

        // Count users by gender
        users.forEach((key, value) {
          final double userLat = value['latitude'];
          final double userLng = value['longitude'];
          final String userGender = value['gender'];

          if (_isWithinArea(userLat, userLng, tappedLocation)) {
            if (userGender == 'Male') {
              localMaleCount++;
            } else if (userGender == 'Female') {
              localFemaleCount++;
            }
          }
        });

        // Fetch city-specific crime data
        final crimeData = await _fetchCrimeData(cityName);

        // Calculate local threat percentage
        int localThreatPercentage = calculateThreatPercentage(localMaleCount, localFemaleCount);
        if (crimeData.containsKey('crimeRate')) {
          localThreatPercentage = crimeData['crimeRate'];
        }

        // Update state
        setState(() {
          maleCount = localMaleCount;
          femaleCount = localFemaleCount;
          threatPercentage = localThreatPercentage;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching area details: $e');
    }
  }

  // Reverse geocoding to get city name
  Future<String> _getCityName(LatLng location) async {
    const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your Google API key
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        for (var component in data['results'][0]['address_components']) {
          if (component['types'].contains('locality')) {
            return component['long_name'];
          }
        }
      }
    }

    return '';
  }

  // Fetch crime data from the API using the city name
  Future<Map<String, dynamic>> _fetchCrimeData(String cityName) async {
    const apiKey = 'YOUR_CRIME_DATA_API_KEY'; // Replace with your crime data API key
    final response = await http.get(
      Uri.parse('https://example-crime-api.com/crime-data?city=$cityName&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return {};
  }

  // Helper function to calculate threat percentage
  int calculateThreatPercentage(int males, int females) {
    if (females == 0) return 0; // Avoid division by zero
    return ((females / (males + females)) * 100).toInt();
  }

  // Helper function to check if a user is within the tapped area
  bool _isWithinArea(double userLat, double userLng, LatLng tappedLocation) {
    const double areaRadius = 0.0001; // Define area radius (adjust as needed)
    final double latDiff = (userLat - tappedLocation.latitude).abs();
    final double lngDiff = (userLng - tappedLocation.longitude).abs();
    return latDiff <= areaRadius && lngDiff <= areaRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Area Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Area Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('City: $cityName'),
                  Text('Males: $maleCount'),
                  Text('Females: $femaleCount'),
                  Text('Threat Percentage: $threatPercentage%'),
                ],
              ),
            ),
    );
  }
}