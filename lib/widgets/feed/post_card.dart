import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: post['userPhotoUrl'] != null && post['userPhotoUrl'].isNotEmpty
                    ? NetworkImage(post['userPhotoUrl'])
                    : null,
                child: post['userPhotoUrl'] == null || post['userPhotoUrl'].isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post['userName'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        if (post['isUserVerified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                      ],
                    ),
                    Text(
                      post['location'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔹 TEXT
          if (post['title'] != null && post['title'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                post['title'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          Text(
            post['description'],
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          /// 🔹 IMAGES
          if (post['imageUrls'] != null && (post['imageUrls'] as List).isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network((post['imageUrls'] as List).first),
            ),

          const SizedBox(height: 10),

          /// 🔹 ACTIONS
          Row(
            children: [
              const Icon(Icons.thumb_up, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${post['likes']}",
                  style: const TextStyle(color: Colors.grey)),

              const SizedBox(width: 20),

              const Icon(Icons.comment, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${post['comments']}",
                  style: const TextStyle(color: Colors.grey)),

              const Spacer(),

              const Icon(Icons.share, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}