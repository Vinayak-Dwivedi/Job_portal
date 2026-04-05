import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final publicProfileProvider = FutureProvider.family<Map<String, dynamic>?, ({String uid, String role})>((ref, arg) async {
  final collection = arg.role == 'employer' ? 'employers' : 'users';
  
  try {
    final doc = await FirebaseFirestore.instance.collection(collection).doc(arg.uid).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  } catch (e) {
    return null;
  }
});
