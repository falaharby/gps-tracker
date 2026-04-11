
import 'package:latlong2/latlong.dart';

// Class Model for State at Tracking Page
class LocationState {
  final bool isLoaded;
  final LatLng center;
  final String? error;

  LocationState({
    this.isLoaded = false,
    required this.center,
    this.error,
  });

  LocationState copyWith({
    bool? isLoaded,
    LatLng? center,
    String? error,
  }) {
    return LocationState(
      isLoaded: isLoaded ?? this.isLoaded,
      center: center ?? this.center,
      error: error ?? this.error,
    );
  }
}
