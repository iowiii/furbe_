import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../core/app_routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final authController = Get.find<DataController>();

  bool isLoading = false;

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
                  "Create an Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Username',
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

              // Phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number (+63xxxxxxxxxx)',
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

              // Password
              TextField(
                controller: passController,
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
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
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

              // Register Button
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
                  onPressed: isLoading
                      ? null
                      : () async {
                    final name = nameController.text.trim();
                    final rawPhone = phoneController.text.trim();
                    final password = passController.text.trim();
                    final confirmPassword =
                    confirmPassController.text.trim();

                    if (name.isEmpty ||
                        rawPhone.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      Get.snackbar('Error', 'Please fill in all fields');
                      return;
                    }
                    if (password != confirmPassword) {
                      Get.snackbar('Error', 'Passwords do not match');
                      return;
                    }
                    String formattedPhone =
                    rawPhone.replaceAll('+', '');
                    if (!formattedPhone.startsWith('63')) {
                      formattedPhone = '63$formattedPhone';
                    }

                    setState(() => isLoading = true);
                    try {
                      await authController.registerUser(
                        name,
                        rawPhone,
                        password,
                        onCodeSent: (verificationId, resendToken) {
                          if (!mounted) return;
                          Get.toNamed(
                            AppRoutes.otp,
                            arguments: {
                              'verificationId': verificationId,
                              'phone': rawPhone,
                              'name': name,
                            },
                          );
                        },
                        onError: (errorMessage) {
                          if (!mounted) return;
                          Get.snackbar('Error', errorMessage);
                        },
                      );
                    } catch (e) {
                      if (!mounted) return;
                      Get.snackbar(
                          'Error', 'Registration failed: $e');
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Sign up",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Spacer(),

              // Bottom link
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.login),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
