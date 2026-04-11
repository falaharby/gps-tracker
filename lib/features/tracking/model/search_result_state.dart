
import 'package:flutter_map/flutter_map.dart';

// Class Model for Selection Location from Search Results at Tracking Page
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
