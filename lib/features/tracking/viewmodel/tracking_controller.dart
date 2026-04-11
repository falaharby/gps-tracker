import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gps_tracking_system/features/tracking/model/location_state.dart';
import 'package:gps_tracking_system/features/tracking/model/search_result_state.dart';
import 'package:gps_tracking_system/features/tracking/model/search_state.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../data/tracking_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/location_history_service.dart';

class TrackingController extends ChangeNotifier {
  final TrackingRepository repository;
  final LocationService locationService;
  final LocationHistoryService locationHistoryService;

  // Search state
  SearchState _searchState = SearchState();
  SearchState get searchState => _searchState;

  // Location state
  LocationState _locationState = LocationState(
    center: LatLng(-7.7844639, 110.4385711), // Default location (Yogyakarta)
  );
  LocationState get locationState => _locationState;

  // Tracking state
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  final List<LatLng> _polylinePoints = [];
  List<LatLng> get polylinePoints => _polylinePoints;

  Polyline? _polyline;
  Polyline? get polyline => _polyline;

  // Search result state
  SearchResultState _searchResultState = SearchResultState();
  SearchResultState get searchResultState => _searchResultState;

  StreamSubscription<Position>? _positionStreamSubscription;
  late final MapController mapController;
  late final TextEditingController searchController;

  TrackingController({
    required this.repository,
    required this.locationService,
    required this.locationHistoryService,
  }) {
    mapController = MapController();
    searchController = TextEditingController();
  }

  // ========== LOCATION INITIALIZATION ==========
  Future<void> initializeLocation() async {
    try {
      // Request location permission
      var permission = await locationService.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await locationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Get current position
        final position = await locationService.getCurrentPosition();
        _locationState = _locationState.copyWith(
          center: LatLng(position.latitude, position.longitude),
          isLoaded: true,
        );
      } else {
        _setDefaultLocation();
      }
    } catch (e) {
      _setDefaultLocation();
    }
    notifyListeners();
  }

  void _setDefaultLocation() {
    _locationState = _locationState.copyWith(
      center: LatLng(-7.7844639, 110.4385711),
      isLoaded: true,
    );
  }

  // ========== SEARCH FUNCTIONALITY ==========
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchState = _searchState.copyWith(results: [], error: null);
      notifyListeners();
      return;
    }

    _searchState = _searchState.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final results = await repository.searchLocation(query);
      _searchState = _searchState.copyWith(
        isLoading: false,
        results: results,
        error: null,
      );
    } catch (e) {
      _searchState = _searchState.copyWith(
        isLoading: false,
        results: [],
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  void clearSearchResults() {
    _searchState = _searchState.copyWith(results: [], error: null);
    notifyListeners();
  }

  // ========== SEARCH RESULT HANDLING ==========
  void selectSearchResult(double lat, double lon, String name) {
    final pos = LatLng(lat, lon);
    
    // Create the marker for search result
    final marker = Marker(
      width: 48,
      height: 48,
      point: pos,
      child: const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 40,
      ),
    );

    _searchResultState = _searchResultState.copyWith(
      hasSelected: true,
      marker: marker,
      displayName: name,
    );
    _locationState = _locationState.copyWith(center: pos);
    notifyListeners();
  }

  void clearSearchResult() {
    _searchResultState = SearchResultState();
    _locationState = _locationState.copyWith(center: _locationState.center);
    notifyListeners();
  }

  // ========== MARKER MANAGEMENT ==========
  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void removeMarker(Marker marker) {
    _markers.remove(marker);
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void updateMarkers(List<Marker> newMarkers) {
    _markers.clear();
    _markers.addAll(newMarkers);
    notifyListeners();
  }

  // ========== TRACKING FUNCTIONALITY ==========
  Future<void> startTracking(Function(LatLng) onLocationUpdate) async {
    if (_isTracking) return;

    try {
      // Cancel any existing subscription first
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      _isTracking = true;
      _currentSessionId = const Uuid().v4();
      _polylinePoints.clear();
      _polyline = null;
      notifyListeners();

      final stream = locationService.startTracking();
      _positionStreamSubscription = stream.listen(
        (Position position) {
          final newPos = LatLng(position.latitude, position.longitude);
          
          // Save location to Hive with sessionId
          final locationPoint = LocationPoint(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
            accuracy: position.accuracy,
            sessionId: _currentSessionId!,
          );
          locationHistoryService.saveLocation(locationPoint);
          
          // Add point to polyline
          _polylinePoints.add(newPos);
          _updatePolyline();
          
          // Remove old position markers
          _markers.removeWhere((marker) {
            if (marker.child is Container) {
              final container = marker.child as Container;
              return container.decoration is BoxDecoration &&
                  (container.decoration as BoxDecoration).color == Colors.blueAccent;
            }
            return false;
          });

          // Add new position marker
          _markers.add(
            Marker(
              width: 24,
              height: 24,
              point: newPos,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withAlpha(153),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          );

          // Update center and trigger callback
          _locationState = _locationState.copyWith(center: newPos);
          onLocationUpdate(newPos);
          notifyListeners();
        },
        onError: (error) {
          _isTracking = false;
          _currentSessionId = null;
          _positionStreamSubscription = null;
          locationService.stopTracking();
          notifyListeners();
        },
      );
    } catch (e) {
      _isTracking = false;
      _currentSessionId = null;
      _positionStreamSubscription = null;
      await locationService.stopTracking();
      notifyListeners();
    }
  }

  void _updatePolyline() {
    if (_polylinePoints.isNotEmpty) {
      _polyline = Polyline(
        points: _polylinePoints,
        color: Colors.blue,
        strokeWidth: 3,
      );
    }
  }

  Future<void> stopTracking() async {
    _isTracking = false;
    _currentSessionId = null;
    _polylinePoints.clear();
    _polyline = null;
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    await locationService.stopTracking();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
