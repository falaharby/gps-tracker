import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';
import 'package:gps_tracking_system/core/services/location_history_service.dart';
import 'package:latlong2/latlong.dart';

class HistoryController extends ChangeNotifier {
  final LocationHistoryService _locationHistoryService;

  List<LocationPoint> _locations = [];
  bool _isLoading = false;
  String? _error;

  List<LocationPoint> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get locationCount => _locations.length;
  bool get isEmpty => _locations.isEmpty;

  HistoryController({
    required LocationHistoryService locationHistoryService,
  }) : _locationHistoryService = locationHistoryService;

  bool _isListening = false;

  /// Async initialization. Call this after creating the controller.
  Future<void> init() async {
    // Ensure the history service has opened its Hive box first
    try {
      await _locationHistoryService.init();
    } catch (_) {
    }

    await _loadLocations();
    await _listenToBackgroundService();
  }

  Future<void> _listenToBackgroundService() async {
    if (_isListening) return;
    _isListening = true;
    final service = FlutterBackgroundService();

    // Refresh data when there's location update
    service.on('locationUpdate').listen(
      (event) async {
        final latitude = event?['latitude'] as double? ?? 0;
        final longitude = event?['longitude'] as double? ?? 0;
        final newPos = LatLng(latitude, longitude);

        final locationPoint = LocationPoint(
          latitude: newPos.latitude,
          longitude: newPos.longitude,
          sessionId: event?['sessionId'] as String? ?? 'no_session',
          timestamp: DateTime.now(),
          accuracy: event?['accuracy'] is int ? (event?['accuracy'] as int).toDouble() : event?['accuracy'] as double? ?? 0.0,
        );

        // Delegate saving to LocationHistoryService (it manages the Hive box)
        await _locationHistoryService.saveLocation(locationPoint);

        refresh();
      },
    );
  }

  /// Internal load method
  Future<void> _loadLocations() async {
    _setLoading(true);
    _error = null;

    try {
      _locations = _locationHistoryService.getAllLocations();
      _locations = _locations.reversed.toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load locations: ${e.toString()}';
      _locations = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a specific location by index
  Future<void> deleteLocation(int index) async {
    if (index < 0 || index >= _locations.length) {
      _error = 'Invalid location index';
      notifyListeners();
      return;
    }

    try {
      final actualIndex = _locations.length - 1 - index;
      await _locationHistoryService.deleteLocation(actualIndex);
      
      _locations.removeAt(index);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete location: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear all location history
  Future<void> clearAllHistory() async {
    _setLoading(true);
    _error = null;

    try {
      await _locationHistoryService.clearHistory();
      _locations = [];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear history: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await _loadLocations();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
