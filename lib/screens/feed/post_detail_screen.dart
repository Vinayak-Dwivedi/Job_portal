import 'package:flutter/material.dart';
import '../../core/services/post_service.dart';
import '../../widgets/feed/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text('Post', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
            return Center(
              child: Text('Post not found', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16)),
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
