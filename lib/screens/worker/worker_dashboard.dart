import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/worker_provider.dart';
import '../../providers/post_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    final jobsAsyncValue = ref.watch(jobFeedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
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
                      border: Border.all(color: theme.colorScheme.outline, width: 1.5),
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFBBF24), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('KI Job Portal', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
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
                        backgroundColor: theme.colorScheme.outline,
                        backgroundImage: worker?.localImageFile != null ? FileImage(worker!.localImageFile!) : null,
                        child: worker?.localImageFile == null ? Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant, size: 18) : null,
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
        backgroundColor: theme.cardColor,
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
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ready for your next masterpiece?',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
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
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '${worker?.credits ?? 142}',
                        label: 'CREDITS\nLEFT',
                        color: const Color(0xFFFBBF24),
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '92%',
                        label: 'PROFILE\nSTRENGTH',
                        color: const Color(0xFF34D399),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
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
                    Text('Recommended Jobs', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
                    const Text('View All', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FilterChip(label: 'All Trades', isSelected: true, theme: theme),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Plumbing', theme: theme),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Electrical', theme: theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Jobs List ──────────────────────────
              jobsAsyncValue.when(
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('No job postings available.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _DarkJobCard(job: jobs[index], theme: theme);
                    },
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
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
  final ThemeData theme;
  const _FilterChip({required this.label, this.isSelected = false, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
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
  final ThemeData theme;
  const _StatCard({required this.value, required this.label, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0, height: 1.3)),
        ],
      ),
    );
  }
}

class _DarkJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final ThemeData theme;
  const _DarkJobCard({required this.job, required this.theme});

  @override
  Widget build(BuildContext context) {
    final bool isVerified = job['isVerified'] == true;
    final String title = job['jobTitle']?.toString() ?? 'Job Posting';
    final String company = job['companyName']?.toString() ?? 'Unknown Company';
    final String location = job['location']?.toString() ?? '';
    final String salary = job['jobSalary']?.toString() ?? 'Negotiable';
    final createdAt = job['createdAt'];
    
    String postedTime = 'Just now';
    if (createdAt != null) {
      if (createdAt is Timestamp) {
        postedTime = timeago.format(createdAt.toDate());
      }
    }

    String profileUrl = job['profilePhotoUrl']?.toString() ?? '';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  image: profileUrl.isNotEmpty ? DecorationImage(image: NetworkImage(profileUrl), fit: BoxFit.cover) : null,
                ),
                child: profileUrl.isEmpty ? Icon(Icons.business, color: theme.colorScheme.onSurfaceVariant, size: 24) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle, size: 10, color: Color(0xFF34D399)),
                                SizedBox(width: 3),
                                Text('VERIFIED', style: TextStyle(color: Color(0xFF34D399), fontSize: 8, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(Icons.bookmark_border_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$company • $location',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SALARY / RATE', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(salary, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF60A5FA))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('POSTED', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(postedTime, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share_rounded, color: theme.colorScheme.onSurface, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
