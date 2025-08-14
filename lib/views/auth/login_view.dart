import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  String? verificationId;
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone (+countrycode)')),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                auth.sendOtp(phoneCtrl.text.trim(), (vid) {
                  verificationId = vid;
                  Get.snackbar('OTP', 'Code sent');
                });
              },
              child: const Text('Send OTP'),
            ),
            const SizedBox(height: 12),
            TextField(controller: otpCtrl, decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () async {
                  if (verificationId == null) {
                    Get.snackbar('OTP', 'Send OTP first');
                    return;
                  }
                  try {
                    await auth.verifyOtp(verificationId!, otpCtrl.text.trim());
                    Get.offAllNamed(AppRoutes.home);
                  } catch (e) {
                    Get.snackbar('OTP', e.toString());
                  }
                },
                child: const Text('Verify & Login')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Get.toNamed(AppRoutes.register), child: const Text('Register')),
          ]),
        ),
      ),
    );
  }
}
