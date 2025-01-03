// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hershield/screens/area_profile.dart';
// import '../services/map_services.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final MapService _mapService = MapService();
//   LatLng? _currentLocation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentLocation();
//   }

//   Future<void> _fetchCurrentLocation() async {
//     final location = await _mapService.getCurrentLocation();
//     setState(() {
//       _currentLocation = location;
//     });

//     // Move to location after ensuring map is initialized
//     if (_mapService.isMapInitialized) {
//       _mapService.moveToLocation(location);
//     }
//   }

//   void _onMapTapped(LatLng location) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AreaProfileScreen(tappedLocation: location),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Map Integration"),
//       ),
//       body: _currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               onMapCreated: (controller) {
//                 _mapService.onMapCreated(controller);

//                 // If location is already fetched, move camera
//                 if (_currentLocation != null) {
//                   _mapService.moveToLocation(_currentLocation!);
//                 }
//               },
//               initialCameraPosition: CameraPosition(
//                 target: _currentLocation!,
//                 zoom: 15,
//               ),
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               onTap: _onMapTapped,
//             ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hershield/screens/area_profile.dart';
import '../services/map_services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final location = await _mapService.getCurrentLocation();
    setState(() {
      _currentLocation = location;
    });

    // Move to location after ensuring map is initialized
    if (_mapService.isMapInitialized) {
      _mapService.moveToLocation(location);
    }
  }

  void _onMapTapped(LatLng location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaProfileScreen(tappedLocation: location),
      ),
    );
  }


  void _zoomToCurrentLocation() {
    if (_currentLocation != null) {
      _mapService.zoomToLocation(_currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Area Profiling"),
        centerTitle: true,
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapService.onMapCreated(controller);

                    // If location is already fetched, move camera
                    if (_currentLocation != null) {
                      _mapService.moveToLocation(_currentLocation!);
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: _onMapTapped,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "recentre",
                        onPressed: () {
                          if (_currentLocation != null) {
                            _mapService.moveToLocation(_currentLocation!);
                          }
                        },
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        heroTag: "zoom",
                        onPressed: _zoomToCurrentLocation,
                        child: const Icon(Icons.zoom_in),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}