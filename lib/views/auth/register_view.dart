import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
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
  final authController = Get.find<AuthController>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Register',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 24),

              // Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (+63xxxxxxxxxx)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    final name = nameController.text.trim();
                    final rawPhone = phoneController.text.trim();
                    final password = passController.text.trim();
                    final confirmPassword = confirmPassController.text.trim();

                    if (name.isEmpty || rawPhone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                      Get.snackbar('Error', 'Please fill in all fields');
                      return;
                    }

                    if (password != confirmPassword) {
                      Get.snackbar('Error', 'Passwords do not match');
                      return;
                    }

                    String formattedPhone = rawPhone.replaceAll('+', '');
                    if (!formattedPhone.startsWith('63')) formattedPhone = '63$formattedPhone';

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
                      Get.snackbar('Error', 'Registration failed: $e');
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
