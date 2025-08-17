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

              // Name input
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Phone input
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (+63xxxxxxxxxx)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    final name = nameController.text.trim();
                    String rawPhone = phoneController.text.trim();

                    if (name.isEmpty || rawPhone.isEmpty) {
                      Get.snackbar('Error', 'Please fill in all fields');
                      return;
                    }

                    // ✅ Normalize phone number
                    String formattedPhone = rawPhone.replaceAll('+', '');
                    if (!formattedPhone.startsWith('63')) {
                      formattedPhone = '63$formattedPhone';
                    }

                    setState(() => isLoading = true);

                    try {
                      // ✅ 1. Create the account in /accounts/{phone}
                      await authController.registerUser(
                        name,
                        rawPhone,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        },
                      );

                      await authController.startPhoneVerification(
                        formattedPhone,
                            (verificationId, resendToken) {
                          if (!mounted) return;
                          Navigator.pushNamed(
                            context,
                            AppRoutes.otp,
                            arguments: {
                              'verificationId': verificationId,
                              'phone': formattedPhone,
                              'name': name,
                            },
                          );
                        },
                            (errorMessage) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        },
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
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