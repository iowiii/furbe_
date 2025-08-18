import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://furbe-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  DatabaseReference get db => _db;

  Future<void> registerUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _db.child('accounts').child(uid).set(userData);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> pushMoodEntry(Map<String, dynamic> data) async {
    try {
      await _db.child('mood_entries').push().set(data);
    } catch (e) {
      // ignore errors - best effort
    }
  }

  Future<void> setUserDog(String phone, String dogId, Map<String, dynamic> dogJson) async {
    await _db.child('accounts').child(phone).child('dogs').child(dogId).set(dogJson);
  }


  Future<void> deleteDog(String phone, String dogId, Map<String, dynamic> dogJson) async {
    await _db.child('accounts').child(phone).child('dogs').child(dogId).remove();
  }
}
