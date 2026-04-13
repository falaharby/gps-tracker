import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling GPS location tracking.
/// Manages permissions, starting/stopping GPS tracking, and location updates.
class LocationService extends ChangeNotifier {
  static const int defaultDistanceFilter = 10; // meters
  static const Duration defaultAccuracy = Duration(seconds: 5);

  /// Get current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position once
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: accuracy, timeLimit: timeout),
    );
  }

  /// Get the last known position
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Calculate distance between two coordinates in meters
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get accuracy location
  Future<LocationAccuracyStatus> getLocationAccuracy() async {
    return await Geolocator.getLocationAccuracy();
  }
}
