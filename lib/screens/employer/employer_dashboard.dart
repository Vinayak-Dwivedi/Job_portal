import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../core/theme/app_colors.dart';

class EmployerDashboardScreen extends ConsumerStatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  ConsumerState<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends ConsumerState<EmployerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      final currentProfile = ref.read(employerProvider);
      if (auth != null && currentProfile == null) {
        ref.read(employerProvider.notifier).loadProfile(auth.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final employer = ref.watch(employerProvider);

    if (employer == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkSurface,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final auth = ref.read(authProvider);
            if (auth != null) await ref.read(employerProvider.notifier).loadProfile(auth.uid);
          },
          backgroundColor: AppColors.darkSurfaceContainerHighest,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                /// ── Header ───────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)]),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.darkSurfaceContainer,
                        backgroundImage: (employer.profilePhotoUrl != null && employer.profilePhotoUrl!.isNotEmpty)
                            ? NetworkImage(employer.profilePhotoUrl!)
                            : null,
                        child: (employer.profilePhotoUrl == null || employer.profilePhotoUrl!.isEmpty)
                            ? const Icon(Icons.business, color: Colors.white70)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${employer.companyName.isNotEmpty ? employer.companyName : employer.contactName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Employer Account • Verified',
                            style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    _buildIconButton(Icons.notifications_none_rounded, () {}),
                  ],
                ),
                const SizedBox(height: 32),

                /// ── Quick Actions Grid (Updated) ──────────────
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _QuickActionTile(
                      label: 'Post a Job',
                      icon: Icons.add_business_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: () => context.push('/employer/create-job'),
                    ),
                    _QuickActionTile(
                      label: 'Create Post',
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFF059669),
                      onTap: () => context.push('/feed/create'),
                    ),
                    _QuickActionTile(
                      label: 'Find Workers',
                      icon: Icons.person_search_rounded,
                      color: const Color(0xFFEA580C),
                      onTap: () => context.go('/employer/workers'),
                    ),
                    _QuickActionTile(
                      label: 'Job Postings',
                      icon: Icons.list_alt_rounded,
                      color: const Color(0xFF1E3A8A),
                      onTap: () => context.go('/employer/my-jobs'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                /// ── Stats Row ────────────────────────────────
                const Text(
                  'Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const _StatCard(
                        label: 'Active Jobs',
                        value: '03',
                        progress: 0.7,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 16),
                      const _StatCard(
                        label: 'Applicants',
                        value: '47',
                        progress: 0.5,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 16),
                      const _StatCard(
                        label: 'Profile Views',
                        value: '1.2k',
                        progress: 0.8,
                        color: Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                /// ── Active Job Posts Section ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Listings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () => context.go('/employer/my-jobs'),
                      child: const Text('View All', 
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const _JobCard(
                  title: 'Senior Carpenter',
                  postedDate: '12 Oct, 2023',
                  tags: ['Woodwork', 'Furniture'],
                  location: 'Mumbai, MH',
                  applicants: 12,
                ),
                const SizedBox(height: 12),
                const _JobCard(
                  title: 'Site Electrician',
                  postedDate: '10 Oct, 2023',
                  tags: ['Wiring', 'Industrial'],
                  location: 'Pune, MH',
                  applicants: 8,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkSurfaceContainerHighest),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkSurfaceContainerHighest),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.darkSurfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkOnSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.darkSurface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String postedDate;
  final List<String> tags;
  final String location;
  final int applicants;

  const _JobCard({
    required this.title,
    required this.postedDate,
    required this.tags,
    required this.location,
    required this.applicants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkSurfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Posted on $postedDate',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkOnSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) => _Tag(t)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.darkOnSurfaceVariant),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.people_alt_rounded, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text('$applicants applicants', style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.darkSurfaceContainerHighest, height: 1),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Manage Listing',
                  style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkSurfaceContainerHighest),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
