import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ───────────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: (employer.profilePhotoUrl != null && employer.profilePhotoUrl!.isNotEmpty)
                        ? NetworkImage(employer.profilePhotoUrl!)
                        : const NetworkImage('https://ui-avatars.com/api/?name=Company&background=000839&color=fff'),
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
                            color: Color(0xFF1D4ED8),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_rounded, color: Color(0xFF475569), size: 28),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Quick Actions Grid ───────────────────────
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                children: [
                  _QuickActionItem(
                    label: 'Post a Job',
                    icon: Icons.business_center_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () => context.push('/employer/create-job'),
                  ),
                  _QuickActionItem(
                    label: 'Find Workers',
                    icon: Icons.person_search_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => context.go('/employer/workers'),
                  ),
                  _QuickActionItem(
                    label: 'My Posts',
                    icon: Icons.list_alt_rounded,
                    color: const Color(0xFFEA580C),
                    onTap: () => context.go('/employer/my-jobs'),
                  ),
                  _QuickActionItem(
                    label: 'Payments',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF1E3A8A),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Stats Row ────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Active Jobs',
                      value: '03',
                      progress: 0.7,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      label: 'Applicants',
                      value: '47',
                      progress: 0.5,
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      label: 'Hired',
                      value: '0',
                      progress: 0.1,
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Active Job Posts Section ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Job Posts',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/employer/my-jobs'),
                    child: const Text('View All', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const _JobCard(
                title: 'Senior Carpenter',
                postedDate: '12 Oct, 2023',
                tags: ['Woodwork', 'Furniture Assembly'],
                location: 'Mumbai, MH',
                applicants: 12,
              ),
              const SizedBox(height: 16),
              const _JobCard(
                title: 'Site Electrician',
                postedDate: '10 Oct, 2023',
                tags: ['Wiring', 'Maintenance'],
                location: 'Pune, MH',
                applicants: 8,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
      ],
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
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Posted on $postedDate',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: tags.map((t) => _Tag(t)).toList(),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.people_rounded, size: 18, color: Color(0xFF059669)),
              const SizedBox(width: 4),
              Text('$applicants applicants', style: const TextStyle(color: Color(0xFF059669), fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {},
            child: const Row(
              children: [
                Text(
                  'View Applicants',
                  style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 15, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF1D4ED8)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
