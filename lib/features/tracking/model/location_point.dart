import 'package:hive/hive.dart';

part 'location_point.g.dart';

@HiveType(typeId: 0)
class LocationPoint {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final double accuracy;

  @HiveField(4)
  final String sessionId;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy = 0.0,
    required this.sessionId,
  });
}
