import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class PostService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // 🔥 Upload Image
  static Future<String> uploadImage(File file) async {
    final ref = _storage
        .ref()
        .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // 🔥 Create Post
  static Future<void> createPost({
    required String userRole,
    required String userName,
    String? userPhotoUrl,
    required bool isUserVerified,
    String? title,
    required String description,
    List<File>? imageFiles,
    String? location,
  }) async {
    List<String> imageUrls = [];

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var file in imageFiles) {
        String url = await uploadImage(file);
        imageUrls.add(url);
      }
    }

    await _firestore.collection('posts').add({
      'userRole': userRole,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl ?? "",
      'isUserVerified': isUserVerified,
      'title': title ?? "",
      'description': description,
      'imageUrls': imageUrls,
      'location': location ?? "",
      'likes': 0,
      'comments': 0,
      'status': 'approved', // Auto-approve for now or set to pending
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 Get Single Post
  static Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      debugPrint("Error fetching post: $e");
      return null;
    }
  }
}