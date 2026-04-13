import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gps_tracking_system/features/tracking/model/location_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_tracking_system/features/setting/data/settings_repository.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

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
      // Use time-based periodic polling instead of movement-based stream
      final settings = SettingsRepository();
      final interval = await settings.getUpdateInterval();
      final accuracyKey = await settings.getAccuracy();

      LocationAccuracy chosenAccuracy;
      switch (accuracyKey) {
        case 'high':
          chosenAccuracy = LocationAccuracy.best;
          break;
        case 'balanced':
          chosenAccuracy = LocationAccuracy.high;
          break;
        case 'low':
          chosenAccuracy = LocationAccuracy.low;
          break;
        default:
          chosenAccuracy = LocationAccuracy.best;
      }

      trackingTimer = Timer.periodic(Duration(seconds: interval), (timer) async {
        try {
          final position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: chosenAccuracy));

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
        } catch (e) {
          service.invoke('trackingError', {"error": e.toString()});
        }
      });

      service.invoke('trackingStarted', {"sessionId": currentSessionId});
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
    // Notify UI that tracking stopped
    service.invoke('trackingStopped', {
      "time": DateTime.now().toString(),
    });
    

    // Stop the background service so the foreground notification is removed
    // and the notification becomes dismissible.
    try {
      service.stopSelf();
    } catch (e) {
      if (service is AndroidServiceInstance) {
        try {
          service.setForegroundNotificationInfo(
            title: "",
            content: "",
          );
        } catch (_) {}
      }
    }
  });

  // Handle stopService command
  service.on('stopService').listen((event) async {
    await positionSubscription?.cancel();
    positionSubscription = null;
    trackingTimer?.cancel();
    trackingTimer = null;
    service.stopSelf();
  });

  // Respond to status queries from UI
  service.on('getStatus').listen((event) async {
    final isTracking = trackingTimer != null || positionSubscription != null;
    try {
      service.invoke('status', {
        'isTracking': isTracking,
        'sessionId': currentSessionId,
      });
    } catch (e) {
      debugPrint('Error invoking status response: $e');
    }
  });

  // Notify UI that service has finished initialization and is ready
  try {
    service.invoke('serviceReady');
  } catch (e) {
    debugPrint('Error invoking serviceReady: $e');
  }
}
