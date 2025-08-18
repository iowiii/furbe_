import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_view.dart';

class OtpVerifiedView extends StatefulWidget {
  const OtpVerifiedView({super.key});

  @override
  State<OtpVerifiedView> createState() => _OtpVerifiedViewState();
}

class _OtpVerifiedViewState extends State<OtpVerifiedView> {
  @override
  void initState() {
    super.initState();
    // Auto navigate to onboarding after 1.5 seconds
    Future.delayed(const Duration(seconds: 1), () {
      Get.off(() => const OnboardingView());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              'Verified',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
