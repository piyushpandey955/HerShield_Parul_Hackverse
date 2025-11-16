
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAreaDetails(widget.tappedLocation);
  }

  String tappedCity = "";
  Future<void> _fetchAreaDetails(LatLng tappedLocation) async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    try {
      // Fetch all users from Firebase
      final usersSnapshot = await usersRef.get();

      int localMaleCount = 0;
      int localFemaleCount = 0;

      if (usersSnapshot.exists) {
        final users = usersSnapshot.value as Map<dynamic, dynamic>;

        // Count users based on gender within the tapped area
        users.forEach((key, value) {
          try {
            final double userLat = value['latitude'] ?? 0.0;
            final double userLng = value['longitude'] ?? 0.0;
            final String userGender = value['gender'] ?? '';

            if (_isWithinArea(userLat, userLng, tappedLocation)) {
              if (userGender == 'Male') {
                localMaleCount++;
              } else if (userGender == 'Female') {
                localFemaleCount++;
              }
            }
          } catch (e) {
            print('Error processing user data: $e');
          }
        });
      }

      // Fetch crime data for the city using the API
      final String city = await _getCityFromCoordinates(tappedLocation);
      tappedCity = city;
      final int crimeCount = await _fetchCrimeData(city);

      // Dynamically calculate threat percentage
      final int localThreatPercentage =
          calculateThreatPercentage(crimeCount, localMaleCount, localFemaleCount);

      // Update the state with the results
      setState(() {
        maleCount = localMaleCount;
        femaleCount = localFemaleCount;
        threatPercentage = localThreatPercentage;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching area details: $e');
      // Always stop loading even if there's an error
      setState(() {
        isLoading = false;
      });
    }
  }

  int totalCrimes = 0;
  Future<int> _fetchCrimeData(String city) async {
    try {
      const String apiKey = '579b464db66ec23bdd000001a6076ea5b7fe422d4c30dc4010960e11'; // Replace with your API key
      final response = await http.get(
        Uri.parse('https://api.data.gov.in/resource/5e7e25eb-4cc6-475d-893f-40fc50884eff?api-key=$apiKey&format=json'),
      ).timeout(const Duration(seconds: 15)); // Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        totalCrimes = 0;
        if (data['records'] != null) {
          for (var record in data['records']) {
            if (record['city_col_2_'] != null && 
                record['city_col_2_'].toString().toLowerCase().contains(city.toLowerCase())) {
              for (var entry in record.entries) {
                if (entry.key.startsWith('ipc_') && entry.value is int) {
                  totalCrimes += entry.value as int;
                }
              }
            }
          }
        }

        return totalCrimes;
      } else {
        // Failed to fetch crime data
        return 0;
      }
    } catch (e) {
      // Error fetching crime data
      return 0;
    }
  }

  Future<String> _getCityFromCoordinates(LatLng location) async {
    const String apiKey = 'AIzaSyBwJzPcmVaSXsbhBH8wZRwLouOyIgOunmI'; // Replace with your actual API key
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          // Iterate through the results to find the city component
          for (var component in data['results'][0]['address_components']) {
            if (component['types'].contains('locality')) {
              return component['long_name']; // Return the city name
            }
          }
          return 'Unknown City'; // Fallback if city not found
        } else {
          // Geocoding API Error
          return 'Unknown City';
        }
      } else {
        // HTTP Request Error
        return 'Unknown City';
      }
    } catch (e) {
      // Exception during reverse geocoding
      return 'Unknown City';
    }
  }

  int calculateThreatPercentage(int crimes, int males, int females) {
    // if (males + females == 0) return 0;
    // else print(crimes); // Avoid division by zero
    return (crimes / (10000 + 7000) * 100).toInt();
  }

  bool _isWithinArea(double userLat, double userLng, LatLng tappedLocation) {
    const double areaRadius = 0.01; // Define area radius in degrees
    final double latDiff = (userLat - tappedLocation.latitude).abs();
    final double lngDiff = (userLng - tappedLocation.longitude).abs();
    return latDiff <= areaRadius && lngDiff <= areaRadius;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Area Profile')),
  //     body: isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Area Details',
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Text('Males: $maleCount'),
  //                 Text('Females: $femaleCount'),
  //                 Text('City: $tappedCity'),
  //                 Text('Total Crimes: $totalCrimes'),
  //                 Text('Threat Percentage: $threatPercentage%'),
  //               ],
  //             ),
  //           ),
  //   );
  // }

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
                    'Area Profile Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: const Icon(Icons.location_city, color: Colors.blue),
                      title: Text('City: $tappedCity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: const Icon(Icons.male, color: Colors.blue),
                      title: Text('Males: $maleCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: const Icon(Icons.female, color: Colors.pink),
                      title: Text('Females: $femaleCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: const Icon(Icons.report_problem, color: Colors.red),
                      title: Text('Total Crimes: $totalCrimes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: const Icon(Icons.security, color: Colors.orange),
                      title: Text('Threat Percentage: $threatPercentage%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

