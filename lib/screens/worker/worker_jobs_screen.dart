import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/worker_provider.dart';

class WorkerJobsScreen extends ConsumerStatefulWidget {
  const WorkerJobsScreen({super.key});

  @override
  ConsumerState<WorkerJobsScreen> createState() => _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends ConsumerState<WorkerJobsScreen>
    with SingleTickerProviderStateMixin {
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
    final worker = ref.watch(workerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A), // Deep dark background
      body: Column(
        children: [
          // ── Premium App Bar ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MY CAREER', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text('Job Applications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFE5E7EB), letterSpacing: -0.5)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2563EB), width: 1.5)),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1E293B),
                        backgroundImage: worker?.localImageFile != null ? FileImage(worker!.localImageFile!) : null,
                        child: worker?.localImageFile == null ? const Icon(Icons.person, color: Color(0xFFE5E7EB), size: 20) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // ── Modern Tab Bar ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Dark surface for tab bar
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF94A3B8),
                    indicator: BoxDecoration(
                      color: const Color(0xFF2563EB), // Electric blue
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [Tab(text: 'Applied'), Tab(text: 'Ongoing'), Tab(text: 'Archive')],
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Views ────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppliedTab(),
                _buildPlaceholderTab('No active engagements.', Icons.handshake_rounded),
                _buildPlaceholderTab('No past history.', Icons.archive_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedTab() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _SuccessRateCard().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        
        const Text('RECENT APPLICATIONS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        
        const _JobCard(
          title: 'Senior Site Electrician',
          company: 'Bright Spark Constructions',
          status: 'Interviewing',
          time: '2d ago',
          statusColor: Color(0xFF34D399), // Bright emerald
          logoIcon: Icons.bolt_rounded,
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
        
        const SizedBox(height: 16),
        
        const _JobCard(
          title: 'Master Carpenter',
          company: 'WoodCraft Interiors',
          status: 'Pending Review',
          time: '5h ago',
          statusColor: Color(0xFFFBBF24), // Bright amber
          logoIcon: Icons.chair_rounded,
        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
        
        const SizedBox(height: 16),
        
        const _JobCard(
          title: 'Maintenance Lead',
          company: 'Apex Residential',
          status: 'Rejected',
          time: '1w ago',
          statusColor: Color(0xFFF87171), // Bright red
          logoIcon: Icons.build_rounded,
          isRejected: true,
        ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1, end: 0),
        
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlaceholderTab(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFF151C2B), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF475569), size: 48),
          ),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _JobCard extends StatelessWidget {
  final String title, company, status, time;
  final Color statusColor;
  final IconData logoIcon;
  final bool isRejected;

  const _JobCard({
    required this.title,
    required this.company,
    required this.status,
    required this.time,
    required this.statusColor,
    required this.logoIcon,
    this.isRejected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2B), // Dark surface
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(logoIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isRejected ? const Color(0xFF94A3B8) : const Color(0xFFE5E7EB))),
                    Text(company, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          if (isRejected) ...[
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Divider(color: Color(0xFF1E293B)),
            ),
            const Text(
              'Position filled. Keep applying to stay on top!',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF334155)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Status Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFE5E7EB))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessRateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Vibrant app primary gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -30, bottom: -30, child: Icon(Icons.trending_up_rounded, color: Colors.white.withOpacity(0.1), size: 160)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Text('MATCH SCORE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('85.4%', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Top 12% in Bengaluru', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              const Text('Your profile responsiveness is improving your visibility to top employers.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
