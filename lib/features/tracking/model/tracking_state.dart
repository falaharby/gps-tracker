import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'location_point.dart';

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

class SearchResultState {
  final bool hasSelected;
  final Marker? marker;
  final String displayName;

  SearchResultState({
    this.hasSelected = false,
    this.marker,
    this.displayName = '',
  });

  SearchResultState copyWith({
    bool? hasSelected,
    Marker? marker,
    String? displayName,
  }) {
    return SearchResultState(
      hasSelected: hasSelected ?? this.hasSelected,
      marker: marker ?? this.marker,
      displayName: displayName ?? this.displayName,
    );
  }
}
