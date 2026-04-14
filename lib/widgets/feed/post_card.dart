import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../core/services/post_service.dart';
import '../../providers/application_provider.dart';



import '../../widgets/feed/comment_bottom_sheet.dart';
import '../../widgets/feed/likers_bottom_sheet.dart';


class PostCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _isLiking = false;
  bool _isExpanded = false;

  void _toggleLike(String postId, String uid) async {
    if (_isLiking) return;
    setState(() => _isLiking = true);
    await PostService.toggleLike(postId, uid);
    setState(() => _isLiking = false);
  }

  void _sharePost(String text) {
    Share.share(text);
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postId: postId),
    );
  }

  void _showLikers(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LikersBottomSheet(postId: postId),
    );
  }


  void _applyToJob(BuildContext context, Map<String, dynamic> post, String workerName, String workerPhone, String? imageUrl) async {
    try {
      await ref.read(applicationProvider).applyToJob(
        post: post,
        workerName: workerName,
        workerPhone: workerPhone,
        workerImageUrl: imageUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully! ✅'), backgroundColor: Colors.green),
      );
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('Insufficient credits')) {
        _showInsufficientCreditsDialog(context, errorStr);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top Up Required ⚡'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription-plans');
            },
            child: const Text('Top Up Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final String postId = post['id'] ?? '';

    /// 🔥 SAFE FALLBACKS
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
    final bool isJobPost = post['isJobPost'] ?? false;
    final String jobTitle = post['jobTitle'] ?? 'Job Posting';
    final String jobSalary = post['jobSalary'] ?? 'Negotiable';
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

    final bool isAdminPost = post['isAdmin'] == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: isAdminPost 
          ? (theme.brightness == Brightness.dark ? const Color(0xFF1E1B4B).withOpacity(0.5) : const Color(0xFFEEF2FF))
          : theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAdminPost 
            ? const Color(0xFFFBBF24).withOpacity(0.5) 
            : theme.colorScheme.outline.withOpacity(0.1),
          width: isAdminPost ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: isAdminPost 
              ? const Color(0xFFFBBF24).withOpacity(0.15)
              : Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: isAdminPost ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdminPost)
              GestureDetector(
                onTap: () => context.push('/feed/post/$postId'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'VERIFIED INSTITUTIONAL UPDATE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            /// 🔹 HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/profile/$role/$uid'),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        backgroundImage: (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                            ? NetworkImage(profilePhotoUrl)
                            : null,
                        child: (profilePhotoUrl == null || profilePhotoUrl.isEmpty)
                            ? Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant, size: 22)
                            : null,
                      ),
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
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              if (isVerified) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.verified_rounded, color: theme.colorScheme.primary, size: 16),
                              ],
                              if (post['isAdmin'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars_rounded, color: Colors.white, size: 10),
                                      SizedBox(width: 3),
                                      Text(
                                        'ADMIN',
                                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(
                                timeStr,
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            /// 🔹 JOB DETAILS (IF APPLICABLE)
            if (isJobPost) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () => context.push('/feed/post/$postId'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.08),
                          theme.colorScheme.primary.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.work_rounded, color: theme.colorScheme.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jobTitle,
                                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (location.isNotEmpty)
                                    Text(
                                      location,
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.payments_rounded, color: Colors.green[600], size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      jobSalary,
                                      style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w800, fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('FT/PT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else if (post['isAvailabilityPost'] == true) ...[
              /// 🔹 WORKER AVAILABILITY (Looking for Work)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () => context.push('/feed/post/$postId'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.08),
                          Colors.blue.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person_search_rounded, color: Colors.blue, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jobTitle, // Used for worker position
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (location.isNotEmpty)
                                    Text(
                                      location,
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('AVAILABLE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.request_quote_rounded, color: Colors.blue[600], size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Asks: $jobSalary",
                              style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const Spacer(),
                            if (auth?.role == 'employer')
                              TextButton(
                                onPressed: () => context.push('/profile/$role/$uid'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('HIRE ME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],


            /// 🔹 CONTENT TEXT
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      maxLines: _isExpanded ? null : 4,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (text.length > 200)
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _isExpanded ? 'Show Less' : 'Show More',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            /// 🔹 IMAGE
            if (imageUrl != null && imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2),
                        );
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// 🔹 STATS & ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatIcon(Icons.favorite_rounded, "$likes", Colors.redAccent, theme, 
                    () => _showLikers(context, postId)),

                  const SizedBox(width: 16),
                  _buildStatIcon(Icons.chat_bubble_rounded, "$comments", theme.colorScheme.primary, theme, 
                    () => _showComments(context, postId)),
                  const Spacer(),
                  StreamBuilder<bool>(
                    stream: auth != null ? PostService.isPostLiked(postId, auth.uid) : Stream.value(false),
                    builder: (context, snapshot) {
                      final isLiked = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: isLiked ? Colors.redAccent : theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        onPressed: () {
                          if (auth != null) _toggleLike(postId, auth.uid);
                        },
                      ).animate(target: isLiked ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 200.ms, curve: Curves.elasticOut);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share_rounded, color: theme.colorScheme.onSurfaceVariant, size: 22),
                    onPressed: () => _sharePost(text),
                  ),
                ],
              ),
            ),

            if (isJobPost && auth?.role == 'worker') ...[
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: StreamBuilder<bool>(
                  stream: ref.read(applicationProvider).hasApplied(postId),
                  builder: (context, snapshot) {
                    final hasApplied = snapshot.data ?? false;
                    final worker = ref.watch(workerProvider);
                    return AnimatedContainer(
                      duration: 300.ms,
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: hasApplied ? null : () => _applyToJob(
                          context, 
                          post, 
                          worker?.name ?? 'Karigar', 
                          auth?.phone ?? '', 
                          worker?.profilePhotoUrl
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasApplied ? Colors.green[600] : theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.green[600]?.withOpacity(0.15),
                          disabledForegroundColor: Colors.green[700],

                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: hasApplied ? 0 : 4,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(hasApplied ? Icons.check_circle_rounded : Icons.bolt_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              hasApplied ? 'ALREADY APPLIED' : 'APPLY FOR THIS JOB',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStatIcon(IconData icon, String value, Color color, ThemeData theme, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}