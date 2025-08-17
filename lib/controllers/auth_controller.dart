import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';


class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService firebaseService = FirebaseService();

  final Rxn<User> user = Rxn<User>();
  final DatabaseReference db = FirebaseDatabase.instance.ref();
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

    String normalizedPhone = phone.replaceAll('+', '');
    if (!normalizedPhone.startsWith('63')) {
      normalizedPhone = '63$normalizedPhone';
    }

    final snapshot = await firebaseService.db.child('accounts/$phone').get();
    if (!snapshot.exists || snapshot.value == null) {
      Get.snackbar('Login Error', 'Phone number not registered');
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

  Future<void> startPhoneVerification(
      String phone,
      Function(String, int?) codeSentCallback,
      Function(String) verificationFailedCallback,
      ) async {
    String formattedPhone = phone.startsWith('+')
        ? phone.replaceFirst('+', '')
        : phone;

    if (!formattedPhone.startsWith('63')) {
      formattedPhone = '63$formattedPhone';
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+$formattedPhone',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailedCallback(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSentCallback(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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

  Future<void> registerUser(
      String name,
      String phone, {
        required Function(String verificationId, int? resendToken) onCodeSent,
        required Function(String errorMessage) onError,
      }) async {
    bool exists = await isPhoneRegistered(phone);
    if (exists) {
      onError("Phone number already registered");
      return;
    }

    String normalizedPhone = phone.replaceAll('+', '');
    if (!normalizedPhone.startsWith('63')) {
      normalizedPhone = '63$normalizedPhone';
    }

    await firebaseService.db.child('accounts/$phone').set({
      'name': name,
      'phone': normalizedPhone,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await startPhoneVerification(
      phone,
      onCodeSent,
      onError,
    );
  }


  Future<bool> isPhoneRegistered(String phone) async {
    final snapshot = await firebaseService.db.child('accounts/$phone').get();
    return snapshot.exists && snapshot.value != null;
  }


  Future<void> logout() async {
    await _auth.signOut();
    print("Logged out");
  }

  User? get currentUser => _auth.currentUser;
}
