import 'package:flutter/material.dart';
import 'package:gps_tracking_system/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LocationPointAdapter());
  }

  runApp(const MyApp());
}
