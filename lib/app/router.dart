import 'package:flutter/material.dart';
import 'package:gps_tracking_system/app/main_page.dart';

class AppRouter {
  static const String home = '/';
  static const String history = '/history';
  static const String setting = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case home:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}