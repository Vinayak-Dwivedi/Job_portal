import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/auth_provider.dart';
import '../../core/services/post_service.dart';
import '../../core/theme/app_colors.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _isLiking = false;

  void _toggleLike(String postId, String uid) async {
    if (_isLiking) return;
    setState(() => _isLiking = true);
    await PostService.toggleLike(postId, uid);
    setState(() => _isLiking = false);
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postId: postId),
    );
  }

  void _sharePost(String text) {
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final String postId = post['id'] ?? '';

    /// 🔥 SAFE FALLBACKS (MANDATORY)
    final String uid = post['uid'] ?? '';
    final String name = post['name'] ?? 'Unknown User';
    final String role = post['role'] ?? 'worker';
    final String text = post['text'] ?? '';
    final String? imageUrl = post['imageUrl'];
    final String? profilePhotoUrl = post['profilePhotoUrl'];
    final bool isVerified = post['isVerified'] ?? false;
    final String location = post['location'] ?? '';
    final int likes = post['likes'] ?? 0;
    final int comments = post['comments'] ?? 0;
    final dynamic createdAt = post['createdAt'];

    String timeStr = 'Just now';
    if (createdAt is Timestamp) {
      try {
        final date = createdAt.toDate();
        timeStr = timeago.format(date);
      } catch (e) {
        timeStr = 'Just now';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.symmetric(
          horizontal: BorderSide(color: theme.colorScheme.outline, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/$role/$uid'),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    backgroundImage: (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                        ? NetworkImage(profilePhotoUrl)
                        : null,
                    child: (profilePhotoUrl == null || profilePhotoUrl.isEmpty)
                        ? Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/profile/$role/$uid'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],
                            const SizedBox(width: 4),
                            Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${location.isNotEmpty ? "$location • " : ""}$timeStr',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 CONTENT TEXT
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                text,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, height: 1.5),
              ),
            ),

          const SizedBox(height: 12),

          /// 🔹 IMAGE
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          /// 🔹 STATS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.thumb_up_alt_rounded, color: Colors.blue, size: 14),
                const SizedBox(width: 4),
                Text(
                  "$likes",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showComments(context, postId),
                  child: Text(
                    "$comments comments",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: theme.colorScheme.outline.withOpacity(0.3), indent: 16, endIndent: 16),

          /// 🔹 ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder<bool>(
              stream: auth != null ? PostService.isPostLiked(postId, auth.uid) : Stream.value(false),
              builder: (context, snapshot) {
                final isLiked = snapshot.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded, 
                      'Like', 
                      isLiked ? Colors.blue : theme.colorScheme.onSurfaceVariant,
                      theme,
                      onTap: () {
                        if (auth != null) _toggleLike(postId, auth.uid);
                      }
                    ),
                    _buildActionButton(
                      Icons.chat_bubble_outline_rounded, 
                      'Comment', 
                      theme.colorScheme.onSurfaceVariant,
                      theme,
                      onTap: () => _showComments(context, postId)
                    ),
                    _buildActionButton(
                      Icons.share_rounded, 
                      'Share', 
                      theme.colorScheme.onSurfaceVariant,
                      theme,
                      onTap: () => _sharePost(text)
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, ThemeData theme, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}