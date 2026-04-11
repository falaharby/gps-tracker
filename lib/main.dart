import 'package:flutter/material.dart';
import 'package:gps_tracking_system/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LocationPointAdapter());
  
  runApp(const MyApp());
}