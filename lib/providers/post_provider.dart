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
              'userName': data['userName'] ?? '',
              'description': data['description'] ?? '',
              'imageUrls': data['imageUrls'] ?? [],
              'location': data['location'] ?? '',
              'userRole': data['userRole'] ?? '',
              'userPhotoUrl': data['userPhotoUrl'] ?? '',
              'isUserVerified': data['isUserVerified'] ?? false,
              'title': data['title'] ?? '',
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
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
              'userName': data['userName'] ?? '',
              'description': data['description'] ?? '',
              'imageUrls': data['imageUrls'] ?? [],
              'location': data['location'] ?? '',
              'userRole': data['userRole'] ?? '',
              'userPhotoUrl': data['userPhotoUrl'] ?? '',
              'isUserVerified': data['isUserVerified'] ?? false,
              'title': data['title'] ?? '',
              'likes': data['likes'] ?? 0,
              'comments': data['comments'] ?? 0,
            };
          }).toList());
});