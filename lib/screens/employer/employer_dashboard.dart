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
    final theme = Theme.of(context);

    if (employer == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final auth = ref.read(authProvider);
            if (auth != null) await ref.read(employerProvider.notifier).loadProfile(auth.uid);
          },
          backgroundColor: theme.scaffoldBackgroundColor,
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
                        backgroundColor: theme.cardColor,
                        backgroundImage: (employer.profilePhotoUrl != null && employer.profilePhotoUrl!.isNotEmpty)
                            ? NetworkImage(employer.profilePhotoUrl!)
                            : null,
                        child: (employer.profilePhotoUrl == null || employer.profilePhotoUrl!.isEmpty)
                            ? Icon(Icons.business, color: theme.colorScheme.onSurfaceVariant)
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Employer Account • Verified',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    _buildIconButton(Icons.notifications_none_rounded, theme, () {}),
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
                      theme: theme,
                      onTap: () => context.push('/employer/create-job'),
                    ),
                    _QuickActionTile(
                      label: 'Create Post',
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFF059669),
                      theme: theme,
                      onTap: () => context.push('/feed/create'),
                    ),
                    _QuickActionTile(
                      label: 'Find Workers',
                      icon: Icons.person_search_rounded,
                      color: const Color(0xFFEA580C),
                      theme: theme,
                      onTap: () => context.go('/employer/workers'),
                    ),
                    _QuickActionTile(
                      label: 'Job Postings',
                      icon: Icons.list_alt_rounded,
                      color: const Color(0xFF1E3A8A),
                      theme: theme,
                      onTap: () => context.go('/employer/my-jobs'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                /// ── Stats Row ────────────────────────────────
                Text(
                  'Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Active Jobs',
                        value: '03',
                        progress: 0.7,
                        color: const Color(0xFF2563EB),
                        theme: theme,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        label: 'Applicants',
                        value: '47',
                        progress: 0.5,
                        color: const Color(0xFF059669),
                        theme: theme,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        label: 'Profile Views',
                        value: '1.2k',
                        progress: 0.8,
                        color: const Color(0xFF6366F1),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                /// ── Active Job Posts Section ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Listings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                    ),
                    TextButton(
                      onPressed: () => context.go('/employer/my-jobs'),
                      child: const Text('View All', 
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _JobCard(
                  title: 'Senior Carpenter',
                  postedDate: '12 Oct, 2023',
                  tags: const ['Woodwork', 'Furniture'],
                  location: 'Mumbai, MH',
                  applicants: 12,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _JobCard(
                  title: 'Site Electrician',
                  postedDate: '10 Oct, 2023',
                  tags: const ['Wiring', 'Industrial'],
                  location: 'Pune, MH',
                  applicants: 8,
                  theme: theme,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, ThemeData theme, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: theme.colorScheme.onSurface, size: 24),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.theme,
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
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
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
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.scaffoldBackgroundColor,
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
  final ThemeData theme;

  const _JobCard({
    required this.title,
    required this.postedDate,
    required this.tags,
    required this.location,
    required this.applicants,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
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
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Posted on $postedDate',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
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
            children: tags.map((t) => _Tag(t, theme: theme)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(location, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.people_alt_rounded, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text('$applicants applicants', style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outline, height: 1),
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
  final ThemeData theme;
  const _Tag(this.text, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        text,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
