import 'package:flutter/services.dart';

class DNDService {
  static const MethodChannel _channel = MethodChannel('hershield/dnd');

  /// Checks if DND mode is active
  Future<bool> isDNDActive() async {
    try {
      final bool isActive = await _channel.invokeMethod('isDNDActive');
      return isActive;
    } catch (e) {
      print("Error checking DND status: $e");
      return false; // Default to false if an error occurs
    }
  }
}