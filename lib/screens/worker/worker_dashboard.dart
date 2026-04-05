import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/worker_provider.dart';
import '../../core/demo_data.dart';

import '../../providers/auth_provider.dart';

class WorkerHomeFeed extends ConsumerStatefulWidget {
  const WorkerHomeFeed({super.key});

  @override
  ConsumerState<WorkerHomeFeed> createState() => _WorkerHomeFeedState();
}

class _WorkerHomeFeedState extends ConsumerState<WorkerHomeFeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      final currentProfile = ref.read(workerProvider);
      if (auth != null && currentProfile == null) {
        ref.read(workerProvider.notifier).loadProfile(auth.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final worker = ref.watch(workerProvider);
    final primarySkill = worker?.skills.isNotEmpty == true ? worker!.skills.first : '';

    const allJobs = DemoData.sampleJobs;

    // Recommendation logic: match by skill
    final recommendedJobs = allJobs.where((job) {
      if (primarySkill.isEmpty) return true;
      final jobSkills = (job['skillsRequired'] as List<String>).map((s) => s.toLowerCase()).toList();
      return jobSkills.any((s) => s.contains(primarySkill.toLowerCase()) || primarySkill.toLowerCase().contains(s));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // Dark theme base
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFBBF24), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('KI Job Portal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ),
                  const IconButton(icon: Icon(Icons.notifications_none_rounded, color: Color(0xFF2563EB), size: 26), onPressed: null),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.go('/worker/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF1E293B),
                        backgroundImage: worker?.localImageFile != null ? FileImage(worker!.localImageFile!) : null,
                        child: worker?.localImageFile == null ? const Icon(Icons.person, color: Color(0xFF94A3B8), size: 18) : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        color: const Color(0xFF2563EB),
        backgroundColor: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, ${worker?.name.split(' ')[0] ?? 'Karigar'}',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ready for your next masterpiece?',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // ── Stats row ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '08',
                        label: 'ACTIVE\nJOBS',
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '${worker?.credits ?? 142}',
                        label: 'CREDITS\nLEFT',
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '92%',
                        label: 'PROFILE\nSTRENGTH',
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Promo Banner ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -20,
                        child: Text(
                          'Ad',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                            const SizedBox(height: 8),
                            const Text('Unlock Premium\nLead Packs', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.2)),
                            const SizedBox(height: 6),
                            const Text('Get 20% off on your first credit purchase.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Recommended Horizontal row (Optional Filter) ──────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recommended Jobs', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('View All', style: TextStyle(color: const Color(0xFF60A5FA), fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FilterChip(label: 'All Trades', isSelected: true),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Plumbing'),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Electrical'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Jobs List ──────────────────────────
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recommendedJobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _DarkJobCard(job: recommendedJobs[index]);
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0, height: 1.3)),
        ],
      ),
    );
  }
}

class _DarkJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const _DarkJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    // Just a fun mock tag for UI visual exactly like image
    final bool isVerified = job['company'].toString().toLowerCase().contains('society');
    final bool isHighPay = job['company'].toString().toLowerCase().contains('kitchen');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.water_drop_rounded, color: const Color(0xFF60A5FA), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: -0.5),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text('Posted 2 hours ago • ${job['location'].split(',')[0]}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (isHighPay)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('HIGH\nPAY', style: TextStyle(color: Color(0xFF34D399), fontSize: 8, fontWeight: FontWeight.w900, height: 1.2), textAlign: TextAlign.center),
                )
              else if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('VERIFIED', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 8, fontWeight: FontWeight.w900, height: 1.2)),
                )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Looking for a master plumber for a premium modular kitchen setup. Must have experience with Hansgrohe fittings.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EST. BUDGET', style: TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(job['salaryRange'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF60A5FA))),
                  ],
                ),
              ),
              SizedBox(
                width: 110,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => context.push('/job/${job['id']}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? const Color(0xFF1E293B) : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(isVerified ? 'Apply Now' : 'Apply Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
