import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/worker_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/feed/post_card.dart';


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
    final theme = Theme.of(context);
    final worker = ref.watch(workerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Premium App Bar ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surfaceContainerHighest 
                        : theme.colorScheme.surfaceContainerLowest, 
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [Tab(text: 'New Jobs'), Tab(text: 'Applied'), Tab(text: 'Ongoing')],
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
                _buildNewJobsTab(),
                _buildAppliedTab(),
                _buildPlaceholderTab('No active engagements.', Icons.handshake_rounded),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildNewJobsTab() {
    final jobsAsyncValue = ref.watch(jobFeedProvider);

    return jobsAsyncValue.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return _buildPlaceholderTab('No new jobs available.', Icons.search_off_rounded);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            return PostCard(post: jobs[index]).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildAppliedTab() {
    final jobsAsync = ref.watch(workerAppliedJobsProvider);

    return jobsAsync.when(
      data: (jobs) => ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _SuccessRateCard().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          Text('MY APPLICATIONS', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          if (jobs.isEmpty)
            _buildSmallPlaceholder('No applications yet.', Icons.history_rounded)
          else
            ...jobs.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(post: job).animate().fadeIn().slideX(begin: 0.1, end: 0),
            )),
          const SizedBox(height: 32),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }


  Widget _buildSmallPlaceholder(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }


  Widget _buildPlaceholderTab(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5), size: 48),
          ),
          const SizedBox(height: 20),
          Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn();
  }
}



class _SuccessRateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
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
