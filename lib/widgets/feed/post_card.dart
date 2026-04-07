import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
    if (createdAt != null && createdAt is dynamic) {
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
                const Icon(Icons.thumb_up_alt_outlined, color: Colors.blue, size: 14),
                const SizedBox(width: 4),
                Text(
                  "$likes",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  "$comments comments",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),

          Divider(color: theme.colorScheme.outline, indent: 16, endIndent: 16),

          /// 🔹 ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.thumb_up_off_alt, 'Like', theme),
              _buildActionButton(Icons.comment_outlined, 'Comment', theme),
              _buildActionButton(Icons.share_outlined, 'Share', theme),
              _buildActionButton(Icons.send_outlined, 'Send', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, ThemeData theme) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}