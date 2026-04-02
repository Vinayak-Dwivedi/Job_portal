import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';

// Global approved feed
final feedProvider = StreamProvider<List<PostModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('status', isEqualTo: 'approved')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map((d) => PostModel.fromMap(d.data())).toList());
});

// My posts (all statuses)
final myPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('posts')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => PostModel.fromMap(d.data())).toList());
});

// Admin: pending posts
final pendingPostsProvider = StreamProvider<List<PostModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: false)   // oldest first for admin
      .snapshots()
      .map((snap) => snap.docs.map((d) => PostModel.fromMap(d.data())).toList());
});
