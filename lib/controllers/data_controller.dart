import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
import '../models/app_user.dart';
import '../models/dog.dart' as dog_model;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;


class DataController extends GetxController {
  final supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService firebaseService = FirebaseService();

  final Rxn<User> user = Rxn<User>();
  final Rxn<AppUser> appUser = Rxn<AppUser>();
  var currentDog = Rxn<dog_model.Dog>();
  var dogSaves = <String, List<Map<String, dynamic>>>{}.obs;

  final DatabaseReference db = FirebaseDatabase.instance.ref();

  bool devMode = true;
  String? currentPhone;
  final storage = GetStorage();

  static const String devPhone = "+631111111111";
  static const String devOtp = "123456";
  static const String devVerificationId = "631111111111";

  var currentDogIndex = 0.obs;

  void setDogIndex(int index) {
    currentDogIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.userChanges().listen((u) => user.value = u);
    _loadSession();

    ever(currentDogIndex, (idx) {
      final dogs = appUser.value?.dogs.values.toList() ?? [];
      if (idx < dogs.length) {
        print("🌍 Current Dog Index changed: $idx → ${dogs[idx].name}");
      } else {
        print("⚠️ Invalid dog index: $idx");
      }
    });
  }

  void _saveSession() {
    if (appUser.value != null) {
      storage.write('user', appUser.value!.toMap());
    }
    if (currentDog.value != null) {
      storage.write('currentDogId', currentDog.value!.id);
    }
  }

  void _loadSession() {
    final userData = storage.read('user');
    final dogId = storage.read('currentDogId');

    if (userData != null) {
      appUser.value = AppUser.fromMap(Map<String, dynamic>.from(userData));

      if (dogId != null && appUser.value!.dogs.containsKey(dogId)) {
        currentDog.value = appUser.value!.dogs[dogId];
      }
    }
  }

  void setCurrentDog(dog_model.Dog dog) {
    currentDog.value = dog;
    _saveSession();
  }

  Future<void> updateDog(dog_model.Dog dog) async {
    if (currentPhone == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    try {
      // ✅ Save to Firebase
      await firebaseService.db
          .child('accounts/$currentPhone/dogs/${dog.id}')
          .set(dog.toMap());

      // ✅ Reload user so appUser + currentDog are fresh
      await loadAppUser(currentPhone!);

      // ✅ Set currentDog to updated one
      currentDog.value = appUser.value?.dogs[dog.id];

      Get.snackbar('Success', 'Dog updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update dog: $e');
    }
  }


  Future<void> login(String phone, String? password) async {
    phone = phone.replaceAll(' ', '');
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
      _saveSession();
      Get.offAllNamed(AppRoutes.main);
      return;
    }
  }

  Future<void> addDog({
    required String name,
    required String gender,
    required String type,   // <-- breed is here as type
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

    final dog = dog_model.Dog(
      id: dogId,
      name: name,
      gender: gender,
      type: type,
      info: info,
      photo: photoBase64,
    );

    await firebaseService.setUserDog(currentPhone!, dogId, dog.toMap());
    await loadAppUser(currentPhone!);

    if (appUser.value != null && appUser.value!.dogs.containsKey(dogId)) {
      setCurrentDog(appUser.value!.dogs[dogId]!);
    }
  }

  Future<bool> verifyOtp(String phone, String otpCode) async {
    try {
      String normalizedPhone = phone.replaceAll(RegExp(r'\D'), ''); // remove anything not digits
      normalizedPhone = '+$normalizedPhone'; // E.164 format

      final response = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: normalizedPhone,
        token: otpCode,
      );

      if (response.user != null) {
        currentPhone = normalizedPhone;
        await loadAppUser(currentPhone!);
        return true;
      } else {
        print("⚠️ Supabase verification failed: ${response.user}");
        return false;
      }
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
      return false;
    }
  }


  Future<void> registerUser(
      String name,
      String phone,
      String password, {
        required Function(String message) onCodeSent,
        required Function(String errorMessage) onError,
      }) async {

    bool exists = await isPhoneRegistered(phone);
    phone = phone.replaceAll(' ', '');
    if (exists) {
      onError("Phone number already registered");
      return;
    }

    String normalizedPhone = phone.replaceAll(RegExp(r'\D'), ''); // remove anything not digits
    normalizedPhone = '+$normalizedPhone'; // E.164 format

    // Save user details in Firebase DB as before
    await firebaseService.db.child('accounts/$normalizedPhone').set({
      'name': name,
      'phone': phone,
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
      appUser.value = AppUser.fromMap(Map<String, dynamic>.from(userMap));
      if (appUser.value!.dogs.isNotEmpty) {
        currentDog.value ??= appUser.value!.dogs.values.first;
        print("🔹 CurrentDog set to: ${currentDog.value!.name}");
      }
    } else {
      appUser.value = null;
      currentDog.value = null;
    }
  }

  Future<void> startPhoneVerification(
      String phone,
      Function(String message) codeSentCallback,
      Function(String errorMessage) verificationFailedCallback,
      ) async {
    try {
      String normalizedPhone = phone.replaceAll(RegExp(r'\D'), ''); // digits only
      normalizedPhone = '+$normalizedPhone'; // E.164 format

      print("Sending OTP to $normalizedPhone...");

      // Send OTP
      await supabase.auth.signInWithOtp(phone: normalizedPhone);

      print("OTP request completed");
      codeSentCallback('OTP sent to $normalizedPhone');
    } catch (e) {
      print("OTP request failed: $e");
      verificationFailedCallback(e.toString());
    }
  }


  List<dog_model.Dog> get userDogs {
    final user = appUser.value;
    if (user == null || user.dogs.isEmpty) return [];
    return user.dogs.values.toList();
  }

  Future<void> deleteDog(String dogId) async {
    if (currentPhone == null) return;
    await firebaseService.deleteDog(currentPhone!, dogId, {});
    await firebaseService.db.child('accounts').child(currentPhone!).child('saves').child(dogId).remove();
    currentDog.value = null;
    await loadAppUser(currentPhone!);
  }

  Future<void> logout() async {
    await _auth.signOut();
    user.value = null;
    appUser.value = null;
    currentPhone = null;
    currentDog.value = null;
    print("Logged out");
    Get.offAllNamed(AppRoutes.login);
  }
  User? get currentUser => _auth.currentUser;
}

extension AuthUpdates on DataController {
  Future<void> updateUsername(String newName) async {
    final phone = currentPhone;
    if (phone == null) return;

    await firebaseService.db.child("accounts/$phone/name").set(newName);

    appUser.update((user) {
      if (user != null) user.name = newName;
    });
  }

  Future<void> updatePassword(String newPassword) async {
    final phone = currentPhone;
    if (phone == null) return;

    await firebaseService.db.child("accounts/$phone/password").set(newPassword);

    appUser.update((user) {
      if (user != null) user.password = newPassword;
    });
  }

  DateTime safeParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      print("⚠️ Invalid date string: $dateString");
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  Future<void> fetchDogSaves() async {
    final userPhone = currentPhone;
    final dog = currentDog.value;

    print("📌 fetchDogSaves called for phone=$userPhone, dog=$dog");

    if (userPhone == null || dog == null) {
      print("⚠️ Cannot fetch saves: phone or dog is null");
      return;
    }

    try {
      final ref = firebaseService.db.child('accounts/$userPhone/saves/${dog.id}');
      print("🔗 Firebase ref: $ref");

      final snapshot = await ref.get();
      print("⏳ Firebase snapshot retrieved: exists=${snapshot.exists}, value=${snapshot.value}");

      if (!snapshot.exists || snapshot.value == null) {
        print("⚠️ No saves found for ${dog.id}");
        dogSaves[dog.id] = [];
        return;
      }

      final rawData = Map<String, dynamic>.from(snapshot.value as Map);
      print("📂 Raw data keys: ${rawData.keys}");

      final savesList = rawData.entries.map((entry) {
        final saveData = Map<String, dynamic>.from(entry.value);
        final saveMap = {
          "mood": saveData["mood"] ?? "",
          "dateSave": saveData["dateSave"] ?? "",
          "dogName": saveData["dogName"] ?? "",
          "info": saveData["info"] ?? "",
        };
        print("📝 Parsed save: $saveMap");
        return saveMap;
      }).toList();

      dogSaves[dog.id] = savesList;
      print("✅ Loaded saves for ${dog.id}: ${dogSaves[dog.id]}");
    } catch (e, stack) {
      print("❌ Error fetching saves: $e");
      print(stack);
    }
  }
}
