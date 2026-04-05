import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ✅ Save User (Worker OR Employer)
  static Future<void> saveUser(
      String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': data['name'],
      'phone': data['phone'],
      'role': data['role'],

      'companyName': data['companyName'] ?? '',

      'skills': data['skills'] ?? [],
      'experience': data['experience'] ?? 0,

      'location': {
        'address': data['location'] ?? '',
      },

      'bio': '',
      'documents': [],

      'isSubscribed': false,
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("✅ User saved to Firestore (users collection)");
  }
}