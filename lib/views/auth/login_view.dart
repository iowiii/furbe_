import 'package:firebase_auth/firebase_auth.dart';
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
              const SizedBox(height: 40),

              Image.asset(
                'assets/images/logo_main.png',
                height: 80,
              ),
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
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                    if (rawPhone.isEmpty) {
                      Get.snackbar('Error', 'Phone number cannot be empty');
                      return;
                    }

                    String dbPhone = rawPhone.replaceAll('+', '');
                    if (!dbPhone.startsWith('63')) dbPhone = '63$dbPhone';

                    final snapshot = await auth.firebaseService.db.child('accounts/$rawPhone').get();
                    if (!snapshot.exists || snapshot.value == null) {
                      Get.snackbar('Error', 'Phone number not registered');
                      return;
                    }

                    if (auth.devMode && rawPhone == AuthController.devPhone) {
                      Get.toNamed(AppRoutes.otp, arguments: {
                        'verificationId': AuthController.devVerificationId,
                        'phone': rawPhone,
                      });
                      return;
                    }

                    FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '+$rawPhone',
                      verificationCompleted: (PhoneAuthCredential credential) async {
                        await FirebaseAuth.instance.signInWithCredential(credential);
                        Get.offAllNamed(AppRoutes.home);
                      },
                      verificationFailed: (FirebaseAuthException e) {
                        Get.snackbar('Error', e.message ?? 'Verification failed');
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        Get.toNamed(
                          AppRoutes.otp,
                          arguments: {
                            'verificationId': verificationId,
                            'phone': dbPhone,
                          },
                        );
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
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
