import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';

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
