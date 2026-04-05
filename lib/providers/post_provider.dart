import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final feedProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'id': doc.id,
              'uid': data['uid'] ?? '',
              'name': data['name'] ?? '',
              'text': data['text'] ?? data['description'] ?? '',
              'imageUrl': data['imageUrl'],
              'location': data['location'] ?? '',
              'role': data['role'] ?? data['userRole'] ?? '',
              'profilePhotoUrl': data['profilePhotoUrl'] ?? data['userPhotoUrl'] ?? '',
              'isVerified': data['isVerified'] ?? data['isUserVerified'] ?? false,
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
              'createdAt': data['createdAt'],
            };
          }).toList());
});

final pendingPostsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'id': doc.id,
              'uid': data['uid'] ?? '',
              'name': data['name'] ?? '',
              'text': data['text'] ?? data['description'] ?? '',
              'imageUrl': data['imageUrl'],
              'location': data['location'] ?? '',
              'role': data['role'] ?? data['userRole'] ?? '',
              'profilePhotoUrl': data['profilePhotoUrl'] ?? data['userPhotoUrl'] ?? '',
              'isVerified': data['isVerified'] ?? data['isUserVerified'] ?? false,
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
              'createdAt': data['createdAt'],
            };
          }).toList());
});