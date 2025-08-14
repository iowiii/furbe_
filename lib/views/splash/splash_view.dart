import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () => Get.offAllNamed(AppRoutes.login));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('FurBe', style: TextStyle(fontSize: 36))));
  }
}
