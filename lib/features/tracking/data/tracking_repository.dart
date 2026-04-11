import 'dart:convert';
import 'package:gps_tracking_system/features/tracking/model/search_result.dart';
import 'package:http/http.dart' as http;

class TrackingRepository {
  final httpClient = http.Client();
  final Map<String, List<SearchResult>> _cache = {};
  DateTime? _lastRequest;
  final String _email = 'notes.falaharby@gmail.com';

  TrackingRepository();

  /// Search for locations using Nominatim API
  Future<List<SearchResult>> searchLocation(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    // Return cached results if available
    if (_cache.containsKey(q)) {
      return _cache[q]!;
    }

    // Rate limiting: 1 request per second
    final now = DateTime.now();
    if (_lastRequest != null) {
      final diff = now.difference(_lastRequest!);
      if (diff.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - diff.inMilliseconds));
      }
    }

    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'q': q,
          'format': 'json',
          'limit': '5',
          'email': _email,
        },
      );

      final response = await httpClient.get(uri, headers: {
        'User-Agent': 'gps_tracking_system/1.0 ($_email)',
        'From': _email,
        'Accept-Language': 'en',
      });

      _lastRequest = DateTime.now();

      if (response.statusCode == 200) {
        final List data = json.decode(response.body) as List;
        final results = data
            .map((item) => SearchResult.fromJson(item as Map<String, dynamic>))
            .toList();
        _cache[q] = results;
        return results;
      } else if (response.statusCode == 403) {
        throw Exception('403 Forbidden: Nominatim access denied');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
