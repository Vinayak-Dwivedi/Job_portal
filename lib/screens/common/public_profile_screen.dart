import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/public_user_provider.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String uid;
  final String role;

  const PublicProfileScreen({
    super.key,
    required this.uid,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(publicProfileProvider((uid: uid, role: role)));

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: profileAsyncValue.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text('Profile not found', style: TextStyle(color: Colors.white)),
            );
          }

          final name = data['name'] ?? (role == 'employer' ? data['companyName'] : 'User');
          final profilePhoto = data['profilePhotoUrl'] ?? data['logoUrl'] ?? '';
          final location = data['location'] ?? 'India';
          final bio = data['bio'] ?? data['description'] ?? 'No description provided.';
          final isVerified = data['isVerified'] ?? true;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ── Header Background & Avatar ──────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.darkSurface,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.darkSurfaceContainerHighest,
                          backgroundImage: profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) : null,
                          child: profilePhoto.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white60) : null,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                /// ── Basic Info ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: Colors.blue, size: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.darkOnSurfaceVariant, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today_outlined, color: AppColors.darkOnSurfaceVariant, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            'Joined Mar 2024',
                            style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      /// ── Actions ──────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.darkSurfaceContainerHighest),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// ── About ────────────────────────────────
                      const Text(
                        'About',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bio,
                        style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 15, height: 1.6),
                      ),

                      const SizedBox(height: 32),

                      /// ── Recent Posts / Activity ──────────────
                      const Text(
                        'Recent Activity',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.darkSurfaceContainerHighest),
                        ),
                        child: const Center(
                          child: Text(
                            'No recent activity to show.',
                            style: TextStyle(color: AppColors.darkOnSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
