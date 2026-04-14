import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class PostService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = _storageInstance();

  static FirebaseStorage _storageInstance() {
    try {
      return FirebaseStorage.instance;
    } catch (e) {
      // Fallback for environments where storage might not be initialized correctly
      return FirebaseStorage.instance;
    }
  }

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
    bool isJobPost = false,
    bool isAvailabilityPost = false,
    String? jobTitle,
    String? jobSalary,
    String? companyName,
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
      'isJobPost': isJobPost,
      'isAvailabilityPost': isAvailabilityPost,
      if (jobTitle != null) 'jobTitle': jobTitle,
      if (jobSalary != null) 'jobSalary': jobSalary,
      if (companyName != null) 'companyName': companyName,
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

  // 🔥 Social Interactions
  static Future<void> toggleLike(String postId, String uid) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;

      final likeDoc = await transaction.get(likeRef);

      if (likeDoc.exists) {
        transaction.delete(likeRef);
        transaction.update(postRef, {'likes': FieldValue.increment(-1)});
      } else {
        transaction.set(likeRef, {
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {'likes': FieldValue.increment(1)});
      }
    });
  }

  static Future<void> addComment(String postId, Map<String, dynamic> commentData) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();

    return _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, {
        ...commentData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(postRef, {'comments': FieldValue.increment(1)});
    });
  }

  static Stream<List<Map<String, dynamic>>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  static Stream<bool> isPostLiked(String postId, String uid) {
    if (uid.isEmpty) return Stream.value(false);
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }
}