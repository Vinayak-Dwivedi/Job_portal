import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

// Fetch public profile data from the unified 'users' collection
final publicProfileProvider = FutureProvider.family<Map<String, dynamic>?, ({String uid, String role})>((ref, arg) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(arg.uid).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  } catch (e) {
    return null;
  }
});

// Stream to check if the current user has unlocked the target contact info
final isContactUnlockedProvider = StreamProvider.family<bool, String>((ref, targetUid) {
  final auth = ref.watch(authProvider);
  if (auth == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('contactCredits')
      .doc(auth.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return false;
        final data = doc.data()!;
        final List contactedList = data['contactedUIDs'] ?? [];
        return contactedList.contains(targetUid);
      });
});

// Stream to watch current user's credit balance
final userCreditsProvider = StreamProvider((ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('contactCredits')
      .doc(auth.uid)
      .snapshots()
      .map((doc) => doc.data());
});
