import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';

class LocationHistoryService extends ChangeNotifier {
  static const String boxName = 'location_history';
  Box<LocationPoint>? _box;

  /// Get the box, opening it if needed
  Future<Box<LocationPoint>> _getBox() async {
    _box ??= await Hive.openBox<LocationPoint>(boxName);
    return _box!;
  }

  Future<void> init() async {
    await _getBox();
  }

  /// Save a location point to the history
  Future<void> saveLocation(LocationPoint point) async {
    final box = await _getBox();
    await box.add(point);
  }

  /// Get all saved locations
  List<LocationPoint> getAllLocations() {
    if (_box == null) {
      return [];
    }
    return _box!.values.toList();
  }

  /// Get locations with pagination
  List<LocationPoint> getLocationsPage(int page, int pageSize) {
    if (_box == null) return [];
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, _box!.length);
    if (startIndex >= _box!.length) return [];
    return _box!.values.toList().sublist(startIndex, endIndex);
  }

  /// Clear all location history
  Future<void> clearHistory() async {
    final box = await _getBox();
    await box.clear();
  }

  /// Get the total count of saved locations
  int getLocationCount() => _box?.length ?? 0;

  /// Delete a specific location by index
  Future<void> deleteLocation(int index) async {
    final box = await _getBox();
    await box.deleteAt(index);
  }

  /// Get recent locations (last N locations)
  List<LocationPoint> getRecentLocations(int count) {
    if (_box == null) return [];
    final allLocations = _box!.values.toList();
    if (allLocations.isEmpty) return [];
    final start = (allLocations.length - count).clamp(0, allLocations.length);
    return allLocations.sublist(start);
  }
}
