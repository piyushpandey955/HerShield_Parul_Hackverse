import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapService {
  GoogleMapController? _mapController;

  // Check if the map controller is initialized
  bool get isMapInitialized => _mapController != null;

  // Handle map initialization
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Move the map camera to the given location
  void moveToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 15),
        ),
      );
    }
  }

  // Fetch current location using the location package
  Future<LatLng> getCurrentLocation() async {
    final location = Location();
    final hasPermission = await location.requestPermission();

    if (hasPermission == PermissionStatus.granted) {
      final locData = await location.getLocation();
      return LatLng(locData.latitude!, locData.longitude!);
    } else {
      throw Exception("Location permission not granted");
    }
  }


  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Fetch all users' locations
  Future<Map<String, dynamic>> fetchUserLocations() async {
    final snapshot = await _database.child('users').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

// to zoom to exact user location
  void zoomToLocation(LatLng location) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 18), // Adjust the zoom level as needed
        ),
      );
    }
  
}