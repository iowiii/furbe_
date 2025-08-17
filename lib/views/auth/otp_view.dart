import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_routes.dart';


class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final auth = Get.find<AuthController>();
  late String verificationId;
  late String phone;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    verificationId = args['verificationId'];
    phone = args['phone'];
    print("Received verificationId: $verificationId, phone: $phone");
  }

  Future<void> submitOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      Get.snackbar('Error', 'Please enter all 6 digits');
      return;
    }

    if (verificationId == AuthController.devVerificationId &&
        phone == AuthController.devPhone) {
      print("Dev login successful for $phone");
      auth.user.value = FirebaseAuth.instance.currentUser;
      Get.offAllNamed(AppRoutes.main);
      return;
    }

    final success = await auth.verifyOtp(verificationId, otp);
    if (success) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.snackbar('OTP Error', 'Verification failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'OTP Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Confirm your account by entering the one-time pin code we have sent you.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
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
                  onPressed: submitOtp,
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
