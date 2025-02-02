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

      if (usersSnapshot.exists) {
        final users = usersSnapshot.value as Map<dynamic, dynamic>;

        int localMaleCount = 0;
        int localFemaleCount = 0;

        // Count users based on gender within the tapped area
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

        // Fetch crime data for the city using the API
        final String city = await _getCityFromCoordinates(tappedLocation); // Await the city name
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
      }
    } catch (e) {
      print('Error fetching area details: $e');
    }
  }

  int totalCrimes = 0;
  Future<int> _fetchCrimeData(String city) async {
    print(city);
    try {
      const String apiKey = '579b464db66ec23bdd000001a6076ea5b7fe422d4c30dc4010960e11'; // Replace with your API key
      final response = await http.get(
        // Uri.parse('https://data.gov.in/resource/api-endpoint?city=$city&api-key=$apiKey'),
        Uri.parse('https://api.data.gov.in/resource/5e7e25eb-4cc6-475d-893f-40fc50884eff?api-key=$apiKey&format=json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract and sum up crime data
        // int totalCrimes = 0;
        // for (var record in data['records']) {
        //   // print(record);
        //   // print(record['city_col_2_']);
        //   if (record['city_col_2_'].compareTo('Bengaluru (Karnataka)')==0 || record['city_col_2_'].compareTo('Ahmedabad(Gujarat)')==0 || record['city_col_2_'].compareTo('Chennai (Tamil Nadu)')==0 || record['city_col_2_'].compareTo('Delhi')==0 || record['city_col_2_'].compareTo('Ghaziabad (Uttar Pradesh)')==0 || record['city_col_2_'].compareTo('Hyderabad (Telangana)')==0 ||  record['city_col_2_'].compareTo('Jaipur (Rajasthan)')==0) {
        //     for (var entry in record.entries) {
        //       // print(entry.key);
        //       // print(entry.value);
        //       if (entry.key.startsWith('ipc_') && entry.value is int) {
        //         totalCrimes += entry.value as int;
        //       }
        //     }
        //   }
        // }

        totalCrimes = 0;
        for (var record in data['records']) {
          if (record['city_col_2_'].toString().toLowerCase().contains(city.toLowerCase()) == true) {
            for (var entry in record.entries) {
              if (entry.key.startsWith('ipc_') && entry.value is int) {
                totalCrimes += entry.value as int;
              }
            }
          }
        }

        print(totalCrimes);
        return totalCrimes;
      } else {
        print('Failed to fetch crime data: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching crime data: $e');
      return 0;
    }
  }

  Future<String> _getCityFromCoordinates(LatLng location) async {
    const String apiKey = 'AIzaSyBwJzPcmVaSXsbhBH8wZRwLouOyIgOunmI'; // Replace with your actual API key
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';
        print(apiUrl);

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          // Iterate through the results to find the city component
          for (var component in data['results'][0]['address_components']) {
            if (component['types'].contains('locality')) {
              print(component['long_name']);
              return component['long_name']; // Return the city name
            }
          }
          return 'Unknown City'; // Fallback if city not found
        } else {
          print('Geocoding API Error: ${data['status']}');
          return 'Error: Unable to fetch city';
        }
      } else {
        print('HTTP Request Error: ${response.statusCode}');
        return 'Error: Unable to fetch city';
      }
    } catch (e) {
      print('Exception during reverse geocoding: $e');
      return 'Error: Unable to fetch city';
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

