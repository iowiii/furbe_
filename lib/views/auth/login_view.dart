import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../core/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo_main_zoomed.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login to your Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number Field
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number (+countrycode) no space',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              const SizedBox(height: 28),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE15C31),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final rawPhone = phoneCtrl.text.trim();
                    final password = passCtrl.text.trim();

                    if (rawPhone.isEmpty || password.isEmpty) {
                      Get.snackbar('Error', 'Phone number and password required');
                      return;
                    }

                    // Check DB
                    final snapshot = await auth.firebaseService.db
                        .child('accounts/$rawPhone')
                        .get();
                    if (!snapshot.exists || snapshot.value == null) {
                      Get.snackbar('Error', 'Phone number not registered');
                      return;
                    }

                    final userMap = snapshot.value as Map;
                    if (userMap['password'] != password) {
                      Get.snackbar('Error', 'Incorrect password');
                      return;
                    }

                    await auth.login(rawPhone, password);
                    Get.offAllNamed(AppRoutes.main);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),

              // Bottom Sign Up
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
