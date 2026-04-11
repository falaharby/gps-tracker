
import 'package:gps_tracking_system/features/tracking/model/search_result.dart';

// Class Model for State of Search at Tracking Page
class SearchState {
  final bool isLoading;
  final List<SearchResult> results;
  final String? error;

  SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    List<SearchResult>? results,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}
