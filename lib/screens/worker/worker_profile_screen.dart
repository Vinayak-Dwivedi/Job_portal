import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/worker_provider.dart';
import '../profile/profile_image_picker.dart';
import '../../providers/post_provider.dart';
import '../../widgets/feed/post_card.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  ConsumerState<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends ConsumerState<WorkerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Project images (local mock URLs)
  final List<String> _projectImages = [
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D4ED8),
      body: Column(
        children: [
          // ── Blue header ──────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'The Digital Atelier',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Avatar with verified badge
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    ProfileImagePicker(
                      role: 'worker',
                      currentImageUrl: ref.watch(workerProvider)?.profilePhotoUrl,
                      onUploaded: (url) {
                        final current = ref.read(workerProvider);
                        if (current != null) {
                          ref.read(workerProvider.notifier).updateWorker(
                              current.copyWith(profilePhotoUrl: url, localImageFile: null));
                        }
                      },
                    ),
                    // Verified badge
                    Positioned(
                      bottom: -12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6EE7B7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Color(0xFF047857), size: 11),
                            SizedBox(width: 3),
                            Text(
                              'Verified\nWorker',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Name
                Text(
                  ref.watch(workerProvider)?.name ?? 'Worker',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Skill chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _headerChip(ref.watch(workerProvider)?.skills.firstOrNull ?? 'Skilled Worker'),
                    const SizedBox(width: 8),
                    _headerChip('Plumber'),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                    SizedBox(width: 4),
                    Text('4.8', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Text('(23 reviews)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ── White body ───────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: Column(
                  children: [
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showEditProfileSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D4ED8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Contact',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showEditProfileSheet(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF047857),
                                side: const BorderSide(color: Color(0xFF047857)),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.handshake_outlined, size: 16),
                              label: const Text('Hire',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.bookmark_border,
                                color: Color(0xFF475569), size: 20),
                          ),
                        ],
                      ),
                    ),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF1D4ED8),
                      unselectedLabelColor: const Color(0xFF64748B),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      indicatorColor: const Color(0xFF1D4ED8),
                      indicatorWeight: 2.5,
                      dividerColor: const Color(0xFFE2E8F0),
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'My Posts'),
                        Tab(text: 'Portfolio'),
                        Tab(text: 'Reviews'),
                      ],
                    ),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAboutTab(),
                          _buildMyPostsTab(),
                          _buildPortfolioTab(),
                          _buildReviewsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom nav
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── About tab ──────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    final skills = (ref.watch(workerProvider)?.skills ?? []).isNotEmpty
        ? (ref.watch(workerProvider)?.skills ?? [])
        : ['Wiring', 'Repair', 'Installation', 'Maintenance'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Expertise & Skills'),
          const SizedBox(height: 12),

          // skill pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => _skillPill(s)).toList()
              ..add(_skillPill((ref.watch(workerProvider)?.skills.firstOrNull ?? ''))),
          ),
          const SizedBox(height: 20),

          // Info tiles
          _infoTile(
            icon: Icons.work_outline,
            title: 'Experience',
            subtitle: '${ref.watch(workerProvider)?.skills.length ?? 0}+ years experience',
            iconBg: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF1D4ED8),
          ),
          const SizedBox(height: 10),
          _infoTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Mumbai, Maharashtra',
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF1D4ED8),
          ),
          const SizedBox(height: 10),
          _infoTile(
            icon: Icons.circle,
            title: 'Status',
            subtitle: 'Available Now',
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            subtitleColor: const Color(0xFF059669),
          ),
          const SizedBox(height: 24),

          // Recent Projects header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Recent Projects'),
              const Text(
                'See All',
                style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Project images
          Row(
            children: [
              Expanded(child: _projectImg(_projectImages[0])),
              const SizedBox(width: 12),
              Expanded(child: _projectImg(_projectImages[1])),
            ],
          ),
          const SizedBox(height: 20),

          // Availability banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF047857),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Available for work • Mumbai, Pune',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMyPostsTab() {
    final postsAsync = ref.watch(myPostsProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Text('No posts yet.', style: TextStyle(color: Color(0xFF94A3B8))),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PostCard(post: post),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPortfolioTab() {
    return const Center(
      child: Text('Portfolio coming soon',
          style: TextStyle(color: Color(0xFF94A3B8))),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Text('Reviews coming soon',
          style: TextStyle(color: Color(0xFF94A3B8))),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────
  Widget _headerChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white54),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      );

  Widget _sectionTitle(String title) => Row(
        children: [
          Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
        ],
      );

  Widget _skillPill(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
                fontSize: 13)),
      );

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    Color? subtitleColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: subtitleColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _projectImg(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url,
            height: 120, width: double.infinity, fit: BoxFit.cover),
      );

  // ── Bottom nav ──────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.search_outlined, 'Explore', false),
          _navIcon(Icons.calendar_today_outlined, 'Bookings', false),
          _navIcon(Icons.chat_bubble_outline, 'Messages', false),
          _navIcon(Icons.person, 'Profile', true),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, bool active) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF1D4ED8)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: active ? Colors.white : const Color(0xFF94A3B8),
                size: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFF1D4ED8) : const Color(0xFF94A3B8),
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );


  // ── Edit profile bottom sheet ───────────────────────────────────────
  void _showEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: (ref.read(workerProvider)?.name ?? 'Worker'));
    final skillCtrl = TextEditingController(text: (ref.read(workerProvider)?.skills.firstOrNull ?? ''));
    final expCtrl = TextEditingController(text: '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Edit Profile',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 20),
            _editField(controller: nameCtrl, label: 'Full Name', icon: Icons.person_outline),
            const SizedBox(height: 14),
            _editField(controller: skillCtrl, label: 'Primary Skill', icon: Icons.work_outline),
            const SizedBox(height: 14),
            _editField(
                controller: expCtrl,
                label: 'Experience (years)',
                icon: Icons.timeline,
                keyboard: TextInputType.number),
            const SizedBox(height: 14),
            // Phone – read only
            TextFormField(
              initialValue: (ref.watch(workerProvider)?.phone ?? ''),
              readOnly: true,
              style: const TextStyle(color: Color(0xFF94A3B8)),
              decoration: InputDecoration(
                labelText: 'Phone Number (cannot be changed)',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final current = ref.read(workerProvider);
                  if (current != null) {
                    final newName = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : current.name;
                    final newSkill = skillCtrl.text.trim().isNotEmpty ? skillCtrl.text.trim() : null;
                    final newSkills = newSkill != null ? [newSkill, ...current.skills.skip(1)] : current.skills;
                    ref.read(workerProvider.notifier).updateWorker(
                      current.copyWith(name: newName, skills: newSkills));
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Color(0xFF047857),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save Changes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1D4ED8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
          ),
        ),
      );
}

