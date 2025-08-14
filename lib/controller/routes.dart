import 'package:flutter/material.dart';
import '../views/splash_view.dart';
import 'home_controller.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeController());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text("Error"))),
        );
    }
  }
}
