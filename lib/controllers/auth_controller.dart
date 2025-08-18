import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
import '../models/app_user.dart';
import '../models/dog.dart' as dog_model;
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService firebaseService = FirebaseService();

  final Rxn<User> user = Rxn<User>();
  final Rxn<AppUser> appUser = Rxn<AppUser>();
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  bool devMode = true;
  String? currentPhone;

  static const String devPhone = "+631111111111";
  static const String devOtp = "123456";
  static const String devVerificationId = "631111111111";

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.userChanges().listen((u) => user.value = u);
  }

  Future<void> login(String phone, String? password) async {
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

    if (devMode && phone == devPhone) {
      print("Dev account detected: $phone");
      await loadAppUser(devPhone);
      user.value = null;
      Get.offAllNamed(AppRoutes.main);
      return;
    }

    if (password != null && password.isNotEmpty) {
      final data = snapshot.value as Map;
      if (data['password'] != password) {
        Get.snackbar('Login Error', 'Incorrect password');
        return;
      }

      currentPhone = phone;
      await loadAppUser(phone);
      user.value = null;
      Get.offAllNamed(AppRoutes.main);
      return;
    }
  }

  Future<void> addDog({
    required String name,
    required String gender,
    required String type,
    required String info,
    required String photoPath,
  }) async {
    if (currentPhone == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    final dogId = const Uuid().v4();

    String photoBase64 = '';
    if (photoPath.isNotEmpty) {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      photoBase64 = base64Encode(bytes);
    }

    final dogJson = {
      'id': dogId,
      'name': name,
      'gender': gender,
      'type': type,
      'info': info,
      'photo': photoBase64,
    };

    await firebaseService.setUserDog(currentPhone!, dogId, dogJson);
  }

  Future<bool> verifyOtp(String verificationId, String smsCode) async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(cred);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null && firebaseUser.phoneNumber != null) {
        final normalizedPhone = firebaseUser.phoneNumber!;
        currentPhone = normalizedPhone;
        await loadAppUser(normalizedPhone);
      } else {
        print("⚠️ FirebaseUser or phoneNumber is null");
      }

      return true;
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
      return false;
    }
  }

  Future<void> registerUser(
      String name,
      String phone,
      String password, {
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
      'password': password,
      'saves': {},
      'dogs': {},
    });

    await startPhoneVerification(phone, onCodeSent, onError);
  }

  Future<bool> isPhoneRegistered(String phone) async {
    final snapshot = await firebaseService.db.child('accounts/$phone').get();
    return snapshot.exists && snapshot.value != null;
  }

  Future<void> loadAppUser(String phone) async {
    final snapshot = await firebaseService.db.child('accounts/$phone').get();

    if (snapshot.exists && snapshot.value != null) {
      final userMap = snapshot.value as Map;
      appUser.value = AppUser.fromMap(userMap);
    } else {
      appUser.value = null;
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

  List<dog_model.Dog> get userDogs {
    final user = appUser.value;
    if (user == null || user.dogs.isEmpty) return [];
    return user.dogs.values.toList();
  }

  Future<void> deleteDog(String dogId) async {
    if (currentPhone == null) return;
    await firebaseService.deleteDog(currentPhone!, dogId, {});
    await loadAppUser(currentPhone!);
  }

  Future<void> logout() async {
    await _auth.signOut();
    user.value = null;
    appUser.value = null;
    currentPhone = null;
    print("Logged out");
    Get.offAllNamed(AppRoutes.login);
  }

  User? get currentUser => _auth.currentUser;
}
