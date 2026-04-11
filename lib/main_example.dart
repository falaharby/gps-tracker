import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LocationPointAdapter());
  }

  runApp(MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // 🔥 CREATE NOTIFICATION CHANNEL BEFORE SERVICE STARTS
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'Tracking Service',
    description: 'Tracking is running',
    importance: Importance.low,
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Tracking Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LocationPointAdapter());
  }

  final box = await Hive.openBox<LocationPoint>('locations');

  // ✅ Proper foreground notification (DO NOT create manually)
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Tracking Active",
      content: "Service started...",
    );
  }

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    final now = DateTime.now();

    await box.add(LocationPoint(
      latitude: 0,
      longitude: 0,
      sessionId: 'dummy',
      timestamp: now,
    ));

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Tracking Active",
        content: "Last update: $now",
      );
    }

    service.invoke('update', {
      "time": now.toString(),
    });
  });

  service.on('stopService').listen((event) async {
    await box.close();
    service.stopSelf();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "Waiting...";
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();

    service.on('update').listen((event) {
      setState(() {
        text = event?['time'] ?? 'No data';
      });
    });
  }

  // 🔥 REQUEST PERMISSION BEFORE START
  Future<bool> requestPermissions() async {
    final notif = await Permission.notification.request();
    final location = await Permission.location.request();
    final locationAlways = await Permission.locationAlways.request();

    return notif.isGranted && location.isGranted;
  }

  Future<void> startService() async {
    final granted = await requestPermissions();

    if (!granted) {
      print("Permission not granted");
      return;
    }

    final isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
    }
  }

  void stopService() {
    service.invoke('stopService');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Service')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(text)),
          ElevatedButton(
            onPressed: startService,
            child: Text("Start"),
          ),
          ElevatedButton(
            onPressed: stopService,
            child: Text("Stop"),
          ),
        ],
      ),
    );
  }
}