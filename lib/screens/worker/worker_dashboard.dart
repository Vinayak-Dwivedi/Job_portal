import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/worker_provider.dart';
import '../../core/demo_data.dart';

class WorkerHomeFeed extends ConsumerWidget {
  const WorkerHomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('KI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('BHARAT KARIGAR', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                        Text(
                          'Namaste, ${worker?.name.split(' ')[0] ?? 'Karigar'}',
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const IconButton(icon: Icon(Icons.search, color: Color(0xFF64748B), size: 26), onPressed: null),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.go('/worker/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE2E8F0),
                        backgroundImage: worker?.localImageFile != null ? FileImage(worker!.localImageFile!) : null,
                        child: worker?.localImageFile == null ? const Icon(Icons.person, color: Color(0xFF1D4ED8), size: 20) : null,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stats row ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: _StatCard(
                        icon: Icons.assignment_turned_in_rounded,
                        value: '4',
                        label: 'Active Apps',
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.bolt_rounded,
                        value: '${worker?.credits ?? 0}',
                        label: 'Credits',
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Recommended Horizontal ────────────────────
              if (recommendedJobs.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text('Recommended For You', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      SizedBox(width: 8),
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: recommendedJobs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => SizedBox(
                      width: 300,
                      child: _JobCard(job: recommendedJobs[index], isHorizontal: true),
                    ),
                  ),
                ),
              ],

              // ── All Jobs Section ──────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('All Job Openings', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              ),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allJobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _JobCard(job: allJobs[index]),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 24)),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isHorizontal;
  const _JobCard({required this.job, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (job['color'] as Color? ?? const Color(0xFF1D4ED8)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.business_rounded, color: job['color'] as Color? ?? const Color(0xFF1D4ED8), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['company'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                    Text(job['location'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.bookmark_border_rounded, color: Color(0xFF94A3B8), size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            job['title'],
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A), letterSpacing: -0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Tag(job['skillsRequired'][0]),
              const _Tag('Full-Time'),
            ],
          ),
          const Spacer(),
          const Divider(color: Color(0xFFF1F5F9), height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DAILY EARNING', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    Text(job['salaryRange'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF10B981))),
                  ],
                ),
              ),
              // About Button
              IconButton(
                onPressed: () => context.push('/employer/${job['employerId']}'),
                icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8)),
                tooltip: 'About Employer',
              ),
              const SizedBox(width: 8),
              // Apply Button
              ElevatedButton(
                onPressed: () => context.push('/job/${job['id']}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
