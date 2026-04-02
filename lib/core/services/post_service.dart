import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import 'storage_service.dart';

class PostService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> createPost({
    required String userRole,
    required String userName,
    String? userPhotoUrl,
    required bool isUserVerified,
    required String title,
    required String description,
    required List<File> imageFiles,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postId = _firestore.collection('posts').doc().id;

    // 1. Upload images to Storage (parallel)
    final imageUrls = await Future.wait(
      imageFiles.asMap().entries.map((e) =>
        StorageService.uploadPostImage(uid, postId, e.key, e.value)
      ),
    );

    // 2. Write post document (status = "pending")
    // NOTE: Rule: Posts default to `status: "pending"`
    await _firestore.collection('posts').doc(postId).set({
      'postId': postId,
      'userId': uid,
      'userRole': userRole,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'isUserVerified': isUserVerified,
      'title': title.trim(),
      'description': description.trim(),
      'imageUrls': imageUrls,
      'status': 'pending', 
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
    });

    // 3. Add postId to user's postIds array
    await _firestore.collection('users').doc(uid).update({
      'postIds': FieldValue.arrayUnion([postId]),
    });
  }

  static Future<void> deletePost(String postId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = _firestore.batch();
    
    batch.delete(_firestore.collection('posts').doc(postId));
    batch.update(_firestore.collection('users').doc(uid), {
      'postIds': FieldValue.arrayRemove([postId])
    });

    await batch.commit();
  }

  static Future<PostModel?> getPost(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    if (!doc.exists || doc.data() == null) return null;
    return PostModel.fromMap(doc.data()!);
  }
}
