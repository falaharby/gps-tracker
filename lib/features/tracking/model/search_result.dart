// Class Model for Search Results from Nominatim API
class SearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  SearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'] ?? '${json['lat']}, ${json['lon']}',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
    );
  }
}