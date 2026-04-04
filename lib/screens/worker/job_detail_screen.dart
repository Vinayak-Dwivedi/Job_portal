import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/demo_data.dart';
import '../../providers/worker_provider.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isApplying = false;
  bool _hasApplied = false;

  void _handleApply() async {
    setState(() => _isApplying = true);
    
    // Simulate application process
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isApplying = false;
        _hasApplied = true;
      });
      
      // Auto-dismiss or show success
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = DemoData.sampleJobs.firstWhere(
      (j) => j['id'] == widget.jobId,
      orElse: () => DemoData.sampleJobs.first,
    );
    final worker = ref.watch(workerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Modern AppBar ───────────────────────────
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: const Color(0xFF1D4ED8),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    job['company'],
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
                  ),
                  background: Container(color: const Color(0xFF1D4ED8)),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),

              // ── Job Header ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: (job['color'] as Color? ?? const Color(0xFF1D4ED8)).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.business_rounded, color: job['color'] as Color? ?? const Color(0xFF1D4ED8), size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job['title'],
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Color(0xFF64748B), size: 14),
                                    const SizedBox(width: 4),
                                    Text(job['location'], style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Detailed Info Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoTile(label: 'DAILY WAGE', value: job['salaryRange'], icon: Icons.payments_rounded, color: Colors.green),
                          const _InfoTile(label: 'WORK TYPE', value: 'Full-time', icon: Icons.work_history_rounded, color: Colors.orange),
                          const _InfoTile(label: 'EXPERIENCE', value: '2-3 Years', icon: Icons.star_rounded, color: Colors.blue),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      Text(
                        job['description'],
                        style: const TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.6),
                      ),

                      const SizedBox(height: 32),
                      const Text('Required Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (job['skillsRequired'] as List<String>).map((skill) => _SkillChip(skill)).toList(),
                      ),

                      const SizedBox(height: 120), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Navigation Bar ───────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const IconButton(
                      icon: Icon(Icons.bookmark_border_rounded, color: Color(0xFF1D4ED8)),
                      onPressed: null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _hasApplied || _isApplying ? null : _handleApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasApplied ? const Color(0xFF10B981) : const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isApplying 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text(
                              _hasApplied ? 'Applied Successfully' : 'Apply Now',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Success Overlay ─────────────────────────
          if (_hasApplied)
            Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.network(
                      'https://assets10.lottiefiles.com/packages/lf20_awS8Y6.json', // Checkmark animation
                      width: 200,
                      height: 200,
                      repeat: false,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Application Sent!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The employer has been notified.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;
  const _SkillChip(this.skill);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        skill,
        style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
