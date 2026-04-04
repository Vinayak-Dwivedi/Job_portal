import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // 🔥 Save Employer Data
  static Future<void> saveEmployer(
      String uid, Map<String, dynamic> data) async {
    // 🔹 users collection
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': data['name'],
      'phone': data['phone'],
      'role': 'employer',
      'isSubscribed': false,
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔹 employers collection
    await _db.collection('employers').doc(uid).set({
      'uid': uid,
      'companyName': data['company'],
      'name': data['name'],
      'phone': data['phone'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("✅ Employer saved to Firestore");
  }
}
