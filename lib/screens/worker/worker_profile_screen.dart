import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/worker_provider.dart';

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref.watch(workerProvider);
    final name = worker?.name ?? 'Suresh Kumar';
    final skills = worker?.skills ?? ['UI/UX Design', 'Product Strategy'];
    final phone = worker?.phone ?? '';

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Professional Profile',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // Top Section
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.darkSurfaceContainerHighest,
                        backgroundImage: worker?.profilePhotoUrl != null 
                            ? NetworkImage(worker!.profilePhotoUrl!)
                            : const NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('VERIFIED', style: TextStyle(color: Color(0xFF047857), fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                      SizedBox(width: 4),
                      Text('4.8', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('  •  124 Reviews', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Hire Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/edit-profile');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outline),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Section
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About', style: TextStyle(color: AppColors.primaryContainer, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    'Seasoned professional with a focus on residential and commercial electrical systems and modern plumbing solutions. Committed to safety standards and high-quality craftsmanship in every project.',
                    style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Text('EXPERTISE', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s, style: const TextStyle(color: AppColors.primaryContainer, fontSize: 12)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('SERVICE AREA', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primaryContainer, size: 16),
                      SizedBox(width: 8),
                      Text('Indiranagar, Bangalore', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: const Column(
                children: [
                  Text('5+', style: TextStyle(color: AppColors.primaryContainer, fontSize: 32, fontWeight: FontWeight.w900)),
                  Text('YEARS EXPERIENCE', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: const Column(
                children: [
                  Text('98%', style: TextStyle(color: AppColors.secondary, fontSize: 32, fontWeight: FontWeight.w900)),
                  Text('JOB COMPLETION', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Portfolio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Portfolio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All >', style: TextStyle(color: AppColors.primaryContainer, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildPortfolioItem('https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=400'),
                _buildPortfolioItem('https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=400'),
                _buildPortfolioItem('https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400'),
                _buildPortfolioItem('https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=400'),
              ],
            ),
            const SizedBox(height: 16),

            // Testimonial
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
              ),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"', style: TextStyle(color: AppColors.primaryContainer, fontSize: 32, fontWeight: FontWeight.bold, height: 1)),
                  Text(
                    '"Suresh did an incredible job with our home renovation. He was punctual, professional, and his attention to detail is unmatched in Bangalore."',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.outline,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Aditi Rao', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('VERIFIED CUSTOMER', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 8)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save & Continue
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Save & Continue', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48), // Padding for shell nav
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioItem(String url) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
