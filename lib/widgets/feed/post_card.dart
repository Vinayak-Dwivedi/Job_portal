import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import 'post_image_grid.dart';
import 'package:go_router/go_router.dart';


class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/feed/post/${widget.post.postId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // navigate to user profile
                    // For now handled by public profile view
                    context.push('/worker/${widget.post.userId}'); 
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: widget.post.userPhotoUrl != null && widget.post.userPhotoUrl!.isNotEmpty
                        ? NetworkImage(widget.post.userPhotoUrl!) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.png'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '· ${widget.post.userRole.capitalize()}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          if (widget.post.isUserVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Color(0xFF1D4ED8), size: 14),
                          ]
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeAgo(widget.post.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title
            if (widget.post.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  widget.post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),

            // Description
            if (widget.post.description.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  widget.post.description,
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              
            if (!_isExpanded && widget.post.description.length > 120)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text('...more', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),

            const SizedBox(height: 10),

            // Images
            if (widget.post.imageUrls.isNotEmpty)
              PostImageGrid(urls: widget.post.imageUrls),

            const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(Icons.thumb_up_outlined, 'Like'),
                _actionButton(Icons.chat_bubble_outline, 'Comment'),
                _actionButton(Icons.share_outlined, 'Share'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      if (isEmpty) return this;
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
