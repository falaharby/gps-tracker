import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
