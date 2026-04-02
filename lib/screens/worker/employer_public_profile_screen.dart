import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/demo_data.dart';
import '../../widgets/subscription/subscription_gate_widget.dart';

class EmployerPublicProfileScreen extends StatelessWidget {
  final String employerId;
  const EmployerPublicProfileScreen({super.key, required this.employerId});

  @override
  Widget build(BuildContext context) {
    // Find the employer info or its sample job to extract info
    final firstJob = DemoData.sampleJobs.firstWhere(
      (j) => j['employerId'] == employerId,
      orElse: () => DemoData.sampleJobs.first,
    );

    final employerName = firstJob['company'];
    final employerLogoColor = firstJob['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── Premium Profile Header ───────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1D4ED8),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 24,
                    child: Transform.translate(
                      offset: const Offset(0, 40),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: employerLogoColor.withValues(alpha: 0.1),
                          child: Icon(Icons.business_rounded, color: employerLogoColor, size: 50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Employer Info ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        employerName,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified_rounded, color: Color(0xFF1D4ED8), size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Premier Construction & Infrastructure',
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  const Row(
                    children: [
                      _EmployerStat(label: 'Active Jobs', value: '12', icon: Icons.work_rounded),
                      SizedBox(width: 24),
                      _EmployerStat(label: 'Workers Hired', value: '450+', icon: Icons.people_rounded),
                      SizedBox(width: 24),
                      _EmployerStat(label: 'Rating', value: '4.8/5', icon: Icons.star_rounded, color: Colors.amber),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Text('About Company', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  const SubscriptionGate(
                    featureName: 'Employer Details',
                    requiredTier: 'pro',
                    child: Text(
                      'With over 20 years of experience in leading infrastructure projects across India, our company prides itself on reliability and exceptional craftsmanship. We value our Karigars and ensure a safe, productive environment for every site.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text('Current Openings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ),

          // ── Secondary Job Cards ─────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = DemoData.sampleJobs[index % DemoData.sampleJobs.length];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job['title'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              Text(job['location'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
                      ],
                    ),
                  );
                },
                childCount: 3,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _EmployerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _EmployerStat({required this.label, required this.value, required this.icon, this.color = const Color(0xFF1D4ED8)});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
      ],
    );
  }
}
