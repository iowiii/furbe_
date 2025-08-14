import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> pushMoodEntry(Map<String, dynamic> data) async {
    try {
      await _db.child('mood_entries').push().set(data);
    } catch (e) {
      // ignore errors - best effort
    }
  }

  Future<void> setUserDog(String uid, Map<String, dynamic> dogJson) async {
    await _db.child('users').child(uid).child('dogs').child(dogJson['id']).set(dogJson);
  }

  Future<void> deleteDog(String uid, String dogId) async {
    await _db.child('users').child(uid).child('dogs').child(dogId).remove();
  }
}
