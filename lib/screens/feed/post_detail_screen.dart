import 'package:flutter/material.dart';
import '../../core/services/post_service.dart';
import '../../widgets/feed/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Post', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: PostService.getPost(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          
          final post = snapshot.data;
          if (post == null) {
            return const Center(
              child: Text('Post not found', style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: PostCard(post: post),
          );
        },
      ),
    );
  }
}
