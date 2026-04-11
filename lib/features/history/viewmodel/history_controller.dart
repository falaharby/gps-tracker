import 'package:flutter/material.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';
import 'package:gps_tracking_system/core/services/location_history_service.dart';

class HistoryController extends ChangeNotifier {
  final LocationHistoryService _locationHistoryService;

  // State variables
  List<LocationPoint> _locations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LocationPoint> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get locationCount => _locations.length;
  bool get isEmpty => _locations.isEmpty;

  HistoryController({
    required LocationHistoryService locationHistoryService,
  }) : _locationHistoryService = locationHistoryService {
    _loadLocations();
  }

  /// Internal load method
  Future<void> _loadLocations() async {
    _setLoading(true);
    _error = null;

    try {
      _locations = _locationHistoryService.getAllLocations();
      // Reverse to show most recent first
      _locations = _locations.reversed.toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load locations: ${e.toString()}';
      _locations = [];
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
      // Get the actual index in the original list (reverse mapping)
      final actualIndex = _locations.length - 1 - index;
      await _locationHistoryService.deleteLocation(actualIndex);
      
      // Remove from local list
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
    } catch (e) {
      _error = 'Failed to clear history: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh the locations list
  Future<void> refresh() async {
    await _loadLocations();
  }

  /// Helper to set loading state
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
