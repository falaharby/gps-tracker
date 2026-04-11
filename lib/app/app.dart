import 'package:flutter/material.dart';
import 'package:gps_tracking_system/app/router.dart';
import 'package:provider/provider.dart';
import 'package:gps_tracking_system/features/tracking/providers.dart';
import 'package:gps_tracking_system/features/history/providers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...trackingProviders(),
        ...historyProviders(),
      ],
      child: MaterialApp(
        title: 'GPS Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}