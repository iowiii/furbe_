import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
import '../models/app_user.dart';

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

  /// LOGIN
  Future<void> login(String phone) async {
    if (phone.isEmpty) {
      Get.snackbar('Login Error', 'Phone number cannot be empty');
      return;
    }

    String normalizedPhone = phone.replaceAll('+', '');
    if (!normalizedPhone.startsWith('63')) {
      normalizedPhone = '63$normalizedPhone';
    }

    final snapshot = await firebaseService.db.child('accounts/$normalizedPhone').get();
    if (!snapshot.exists || snapshot.value == null) {
      Get.snackbar('Login Error', 'Phone number not registered');
      return;
    }

    currentPhone = phone;

    // --- Dev Mode Login ---
    if (devMode && phone == devPhone) {
      print("Dev account detected: $phone");
      await loadAppUser(devPhone);

      // Optionally sign in anonymously to have _auth.currentUser not null
      await _auth.signInAnonymously();
      user.value = _auth.currentUser;

      Get.offAllNamed(AppRoutes.main);
      return;
    }

    // --- Normal OTP Flow ---
    try {
      String formattedPhone = phone.startsWith('+') ? phone : '+63$phone';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
          await loadAppUser(currentPhone!);
          Get.offAllNamed(AppRoutes.main);
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

  Future<void> loginWithPassword(String phone, String password) async {
    String normalizedPhone = phone.replaceAll('+', '');
    if (!normalizedPhone.startsWith('63')) {
      normalizedPhone = '63$normalizedPhone';
    }

    final snapshot = await firebaseService.db.child('accounts/$normalizedPhone').get();
    if (!snapshot.exists) {
      Get.snackbar('Login Error', 'Phone number not registered');
      return;
    }

    final data = snapshot.value as Map;
    if (data['password'] != password) { // ⚠️ plain text, use hashing in prod
      Get.snackbar('Login Error', 'Incorrect password');
      return;
    }

    currentPhone = normalizedPhone;
    await loadAppUser(normalizedPhone);

    // (optional) still sign in with Firebase anonymously
    await _auth.signInAnonymously();
    user.value = _auth.currentUser;

    Get.offAllNamed(AppRoutes.main);
  }


  /// OTP VERIFICATION
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
        currentPhone = normalizedPhone; // 👈 save it for later use
        await loadAppUser(normalizedPhone); // 👈 now this will run
      } else {
        print("⚠️ FirebaseUser or phoneNumber is null");
      }

      return true;
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
      return false;
    }
  }


  /// REGISTER
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
      'password': password, // 👈 store it (better: hash it)
    });

    // start OTP if you still want double protection
    await startPhoneVerification(phone, onCodeSent, onError);
  }


  /// CHECK IF PHONE EXISTS
  Future<bool> isPhoneRegistered(String phone) async {
    final snapshot = await firebaseService.db.child('accounts/$phone').get();
    return snapshot.exists && snapshot.value != null;
  }

  /// LOAD APP USER FROM DB
  Future<void> loadAppUser(String phone) async {
    String dbKey = phone.startsWith('+') ? phone : '+$phone';
    print("🔍 Loading AppUser from DB key: $dbKey");

    final snapshot = await firebaseService.db.child('accounts/$phone').get();
    print("📦 Snapshot exists: ${snapshot.exists}, value: ${snapshot.value}");

    if (snapshot.exists && snapshot.value != null) {
      final userMap = snapshot.value as Map;
      print("✅ AppUser map: $userMap");
      appUser.value = AppUser.fromMap(userMap);
      print("🎉 AppUser loaded: name=${appUser.value?.name}, phone=${appUser.value?.phone}");
    } else {
      print("⚠️ No user found in DB for $dbKey");
      appUser.value = null;
    }
  }


  /// START PHONE VERIFICATION (FOR REGISTER)
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

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    user.value = null;
    appUser.value = null;
    currentPhone = null;
    print("Logged out");
    Get.offAllNamed(AppRoutes.login);
  }

  /// GET CURRENT FIREBASE USER
  User? get currentUser => _auth.currentUser;
}
