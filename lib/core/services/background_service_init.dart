import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';
import 'package:geolocator/geolocator.dart';

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

  Timer? trackingTimer;
  StreamSubscription<Position>? positionSubscription;
  String? currentSessionId;

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Tracking Service",
      content: "Ready to track...",
    );
  }

  // Handle startTracking command
  service.on('startTracking').listen((event) async {
    if (trackingTimer != null || positionSubscription != null) {
      return; // Already tracking
    }

    currentSessionId = event?['sessionId'] as String?;

    try {
      // Start listening to position stream
      positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen(
        (Position position) async {
          // Update notification
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "Tracking Active",
              content: "Lat: ${position.latitude.toStringAsFixed(6)}, Lon: ${position.longitude.toStringAsFixed(6)}",
            );
          }

          // Send location update to UI
          service.invoke('locationUpdate', {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "timestamp": DateTime.now().toString(),
            "accuracy": position.accuracy,
            "sessionId": currentSessionId,
          });
        },
        onError: (error) {
          service.invoke('trackingError', {
            "error": error.toString(),
          });
          positionSubscription?.cancel();
          positionSubscription = null;
        },
      );

      service.invoke('trackingStarted', {
        "sessionId": currentSessionId,
      });
    } catch (e) {
      service.invoke('trackingError', {
        "error": e.toString(),
      });
    }
  });

  // Handle stopTracking command
  service.on('stopTracking').listen((event) async {
    await positionSubscription?.cancel();
    positionSubscription = null;
    trackingTimer?.cancel();
    trackingTimer = null;
    currentSessionId = null;

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Tracking Service",
        content: "Stopped",
      );
    }

    service.invoke('trackingStopped', {
      "time": DateTime.now().toString(),
    });
  });

  // Handle stopService command
  service.on('stopService').listen((event) async {
    await positionSubscription?.cancel();
    positionSubscription = null;
    trackingTimer?.cancel();
    trackingTimer = null;
    service.stopSelf();
  });
}
