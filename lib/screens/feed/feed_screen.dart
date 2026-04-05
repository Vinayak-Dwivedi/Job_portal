import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../providers/post_provider.dart';
import '../../widgets/feed/post_card.dart';
import '../../core/theme/app_colors.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsyncValue = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        title: const Text('Community Feed', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
            onPressed: () {},
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.darkOnSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'LATEST'),
            Tab(text: 'TRENDING'),
            Tab(text: 'NETWORK'),
          ],

        ),
      ),
      body: feedAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            backgroundColor: AppColors.darkSurfaceContainerHighest,
            color: AppColors.primary,
            onRefresh: () async => ref.refresh(feedProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: posts.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) return _buildCreatePostArea(context);
                if (index == 1) return _buildPromoCard(context);
                return PostCard(post: posts[index - 2]);
              },
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error loading feed: $err', style: const TextStyle(color: AppColors.error)),
              TextButton(
                onPressed: () => ref.refresh(feedProvider),
                child: const Text('Retry', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, color: AppColors.darkSurfaceContainerHighest, size: 80),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share an update with the community!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/feed/create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Start a Conversation', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => PostCard(
          post: {
            'name': 'Loading Name',
            'text': 'This is a sample loading text to show the skeleton effect in the feed screen.',
            'location': 'Loading Location',
            'role': 'worker',
            'likes': 0,
            'comments': 0,
          },
        ),
      ),
    );
  }

  Widget _buildCreatePostArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.darkSurfaceContainerHighest, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.darkSurfaceContainerHighest,
                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User&background=1D4ED8&color=fff'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/feed/create'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.darkSurfaceContainerHighest),
                    ),
                    child: const Text('Share your professional updates...', 
                      style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPostAction(Icons.image_outlined, 'Photo', Colors.blue),
              _buildPostAction(Icons.videocam_outlined, 'Video', Colors.green),
              _buildPostAction(Icons.event_note_outlined, 'Event', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => context.push('/feed/create'),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get KI Verified Today',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Boost your profile visibility by 3x and get premium job alerts.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    );
  }
}

