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
  final passCtrl = TextEditingController();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo_main.png', height: 80),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login to your Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Input
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number (+countrycode)',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
              const SizedBox(height: 16),
              // Password Input
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    final rawPhone = phoneCtrl.text.trim();
                    final password = passCtrl.text.trim();

                    if (rawPhone.isEmpty || password.isEmpty) {
                      Get.snackbar('Error', 'Phone number and password required');
                      return;
                    }

                    String dbPhone = rawPhone.replaceAll('+', '');
                    if (!dbPhone.startsWith('63')) dbPhone = '63$dbPhone';

                    final snapshot = await auth.firebaseService.db.child('accounts/$dbPhone').get();
                    if (!snapshot.exists || snapshot.value == null) {
                      Get.snackbar('Error', 'Phone number not registered');
                      return;
                    }

                    final userMap = snapshot.value as Map;
                    if (userMap['password'] != password) {
                      Get.snackbar('Error', 'Incorrect password');
                      return;
                    }

                    await auth.loadAppUser(dbPhone);
                    Get.offAllNamed(AppRoutes.main);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
