
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:hershield/services/alert_nearbyuser_service.dart';
// import 'package:hershield/services/fcmToken_service.dart';
// import 'services/firebase_service.dart';
// import 'services/location_service.dart';
// import 'auth/auth_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final FirebaseService _firebaseService = FirebaseService();
//   final AuthService auth = AuthService();

//   bool _isPanicActive = false; // To track panic button state
//   int _countdown = 5; // Timer countdown
//   Timer? _timer; // Timer instance

//   @override
//   void initState() {
//     super.initState();
//     startRealTimeLocationTracking();
//     saveTokenToDatabase(); // Save FCM token
//   }

//   void startRealTimeLocationTracking() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check location services and permissions
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     final FirebaseAuth auth = FirebaseAuth.instance;
//     final User? user = auth.currentUser;
//     Position position = await LocationService.getCurrentLocation();
//     await _firebaseService.updateUserLocation(
//         user?.uid ?? '', position.latitude, position.longitude);

//     LocationService.getRealTimeLocation().listen((Position position) async {
//       double latitude = position.latitude;
//       double longitude = position.longitude;
//       await _firebaseService.updateUserLocation(
//           user?.uid ?? '', latitude, longitude);
//     });
//   }

//   // Start the countdown for panic button
//   void _startCountdown() {
//     setState(() {
//       _isPanicActive = true;
//       _countdown = 5;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_countdown > 0) {
//           _countdown--;
//         } else {
//           _triggerPanic();
//           _timer?.cancel();
//         }
//       });
//     });
//   }

//   // Cancel the panic alert
//   void _cancelPanic() {
//     setState(() {
//       _isPanicActive = false;
//       _countdown = 5;
//     });
//     _timer?.cancel();
//   }

//   // Trigger the panic alert
//   void _triggerPanic() async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Panic Alert Sent!")),
//     );

//     Position position =
//         await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     double currentLat = position.latitude;
//     double currentLng = position.longitude;
//     double radiusInMeters = 500000; // Example radius
//     final nearbyTokens = await getNearbyUsersFCMTokens(
//         currentLat, currentLng, radiusInMeters);

//     if (nearbyTokens.isNotEmpty) {
//       await sendNotificationToNearbyUsers(
//         tokens: nearbyTokens,
//         title: "Emergency Alert!",
//         body: "Someone nearby needs your help!",
//         latitude: currentLat,
//         longitude: currentLng,
//       );

//       // Notify the current user about the count of alerted users
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "${nearbyTokens.length} people have been alerted and may come to help you.",
//               style: const TextStyle(fontSize: 16),
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//     } else {
//       // No nearby users found
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("No nearby users found to send notifications."),
//             backgroundColor: Colors.red,
//           ),
//         );
//         print("No nearby users found to send notifications.");
//       }

//     setState(() {
//       _isPanicActive = false;
//       _countdown = 5;
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "HerShield",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         // backgroundColor: Colors.blue, // Change color as needed
//         centerTitle: true, // Centers the title text
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "EMERGENCY HELP NEEDED?",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "(Press the button to notify bystanders and police)",
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             GestureDetector(
//               onTap: () {
//                 if (_isPanicActive) {
//                   _cancelPanic(); // Cancel if already active
//                 } else {
//                   _startCountdown(); // Start panic process
//                 }
//               },
//               child: Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: _isPanicActive ? Colors.red : Colors.blue,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 alignment: Alignment.center,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Text(
//                       _isPanicActive ? "$_countdown" : "Click to Ask for Help",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: _isPanicActive ? 32 : 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Help is just a moment away!",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hershield/services/alert_nearbyuser_service.dart';
import 'package:hershield/services/fcmToken_service.dart';
import 'services/firebase_service.dart';
import 'services/location_service.dart';
import 'auth/auth_service.dart';
import 'package:hershield/services/panic_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService auth = AuthService();
  final PanicService _panicService = PanicService();

  bool _isPanicActive = false;
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startRealTimeLocationTracking();
    saveTokenToDatabase();
  }

  void startRealTimeLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    Position position = await LocationService.getCurrentLocation();
    await _firebaseService.updateUserLocation(
        user?.uid ?? '', position.latitude, position.longitude);

    LocationService.getRealTimeLocation().listen((Position position) async {
      double latitude = position.latitude;
      double longitude = position.longitude;
      await _firebaseService.updateUserLocation(
          user?.uid ?? '', latitude, longitude);
    });
  }

  void _startCountdown() {
    setState(() {
      _isPanicActive = true;
      _countdown = 5;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _triggerPanic();
          _timer?.cancel();
        }
      });
    });
  }

  void _cancelPanic() {
    setState(() {
      _isPanicActive = false;
      _countdown = 5;
    });
    _timer?.cancel();
  }

  void _triggerPanic() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Panic Alert Sent!")),
    );

    await _panicService.startRecording();
    
    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double currentLat = position.latitude;
    double currentLng = position.longitude;
    double radiusInMeters = 500000;
    final nearbyTokens = await getNearbyUsersFCMTokens(
        currentLat, currentLng, radiusInMeters);

    if (nearbyTokens.isNotEmpty) {
      await sendNotificationToNearbyUsers(
        tokens: nearbyTokens,
        title: "Emergency Alert!",
        body: "Someone nearby needs your help!",
        latitude: currentLat,
        longitude: currentLng,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${nearbyTokens.length} people have been alerted and may come to help you.",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No nearby users found to send notifications."),
          backgroundColor: Colors.red,
        ),
      );
      print("No nearby users found to send notifications.");
    }

    setState(() {
      _isPanicActive = false;
      _countdown = 5;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HerShield",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "EMERGENCY HELP NEEDED?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "(Press the button to notify bystanders and police)",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (_isPanicActive) {
                  _cancelPanic();
                } else {
                  _startCountdown();
                }
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _isPanicActive ? Colors.red : Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      _isPanicActive ? "$_countdown" : "Click to Ask for Help",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isPanicActive ? 32 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Help is just a moment away!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}