import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rxn<User> user = Rxn<User>();
  bool devMode = true;
  String? currentPhone;

  static const String devPhone = "+631111111111";
  static const String devOtp = "123456";
  static const String devVerificationId = "631111111111";
  //kevinigga sana kaso wag na pala, behave muna pala ako
  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.userChanges().listen((u) => user.value = u);
  }

  Future<void> login(String phone) async {
    if (phone.isEmpty) {
      Get.snackbar('Login Error', 'Phone number cannot be empty');
      return;
    }

    currentPhone = phone;

    if (devMode && phone == devPhone) {
      print("Dev account detected: $phone");
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'verificationId': devVerificationId,
          'phone': phone,
        },
      );
      return;
    }

    try {
      String formattedPhone = phone.startsWith('+') ? phone : '+63$phone';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          Get.snackbar('OTP Error', e.message ?? 'Verification failed');
        },
        codeSent: (verificationId, resendToken) {
          print("OTP sent: $verificationId");
          Get.toNamed(
            AppRoutes.otp,
            arguments: {
              'verificationId': verificationId,
              'phone': formattedPhone,
            },
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
    }
  }

  Future<bool> verifyOtp(String verificationId, String smsCode) async {
    if (devMode && verificationId == devVerificationId && currentPhone == devPhone) {
      if (smsCode == devOtp) {
        print("Dev login successful for $devPhone");
        user.value = _auth.currentUser;
        return true;
      } else {
        Get.snackbar('OTP Error', 'Invalid OTP for dev account');
        return false;
      }
    }

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(cred);
      return true;
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    print("Logged out");
  }

  User? get currentUser => _auth.currentUser;
}
