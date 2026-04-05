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

  // 🔥 Create Post (Unified Schema)
  static Future<void> createPost({
    required String uid,
    required String name,
    required String role,
    required String text,
    List<File>? imageFiles,
    String? location,
    String? profilePhotoUrl,
    required bool isVerified,
  }) async {
    String? imageUrl;

    if (imageFiles != null && imageFiles.isNotEmpty) {
      // For the unified schema we take the first image if multiple are provided
      imageUrl = await uploadImage(imageFiles.first);
    }

    await _firestore.collection('posts').add({
      'uid': uid,
      'name': name,
      'role': role,
      'text': text,
      'imageUrl': imageUrl,
      'location': location ?? "",
      'profilePhotoUrl': profilePhotoUrl ?? "",
      'isVerified': isVerified,
      'likes': 0,
      'comments': 0,
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