import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/public_user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/firestore_service.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String uid;
  final String role;

  const PublicProfileScreen({
    super.key,
    required this.uid,
    required this.role,
  });

  void _handleUnlock(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      await FirestoreService.unlockContactInfo(
        viewerUid: auth.uid,
        targetUid: uid,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact details unlocked successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider((uid: uid, role: role)));
    final isUnlockedAsync = ref.watch(isContactUnlockedProvider(uid));
    final creditsAsync = ref.watch(userCreditsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: profileAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Profile not found', style: TextStyle(color: Colors.white)));
          }

          final name = data['name'] ?? (role == 'employer' ? data['companyName'] : 'User');
          final profilePhoto = data['profilePhotoUrl'] ?? '';
          final location = data['location'] is Map ? (data['location']['address'] ?? 'India') : (data['location'] ?? 'India');
          final bio = data['bio'] ?? 'No description provided.';
          final skills = List<String>.from(data['skills'] ?? []);
          final experience = data['experience'] ?? 0;
          final isVerified = data['isVerified'] ?? false;
          final phone = data['phone'] ?? '';
          final email = data['email'] ?? '';
          final documents = List<dynamic>.from(data['documents'] ?? []);

          return isUnlockedAsync.when(
            data: (isUnlocked) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ── HEADER ──────────────────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: AppColors.darkSurface, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.darkSurfaceContainerHighest,
                              backgroundImage: profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) : null,
                              child: profilePhoto.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white60) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    /// ── BASIC INFO ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                              if (isVerified) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.verified, color: Colors.blue, size: 20)),
                            ],
                          ),
                          Text(role.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.darkOnSurfaceVariant, size: 16),
                              const SizedBox(width: 4),
                              Text(location, style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13)),
                              if (role == 'worker') ...[
                                const SizedBox(width: 16),
                                const Icon(Icons.work_outline_rounded, color: AppColors.darkOnSurfaceVariant, size: 16),
                                const SizedBox(width: 4),
                                Text('$experience Years exp', style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),

                          /// ── CONTACT INFO (LOCKED/UNLOCKED) ─────
                          _buildContactSection(context, ref, isUnlocked, phone, email, creditsAsync),

                          const SizedBox(height: 32),

                          /// ── SKILLS ─────────────────────────────
                          if (skills.isNotEmpty) ...[
                            const Text('Skills', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: skills.map((s) => Chip(
                                label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                backgroundColor: AppColors.darkSurfaceContainerHighest,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              )).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],

                          /// ── ABOUT ─────────────────────────────
                          const Text('About', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(bio, style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 14, height: 1.6)),

                          const SizedBox(height: 32),

                          /// ── DOCUMENTS ─────────────────────────
                          if (documents.isNotEmpty) ...[
                            const Text('Documents', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ...documents.map((doc) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.darkSurfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.darkSurfaceContainerHighest),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.description_outlined, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Text(doc is String ? doc.split('/').last : 'Document', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  const Spacer(),
                                  const Icon(Icons.verified_user_outlined, color: Colors.green, size: 18),
                                ],
                              ),
                            )),
                            const SizedBox(height: 40),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, WidgetRef ref, bool isUnlocked, String phone, String email, AsyncValue creditsAsync) {
    if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            _buildInfoRow(Icons.phone_android_rounded, phone.isNotEmpty ? phone : "Not provided"),
            const Divider(height: 24, color: AppColors.darkSurfaceContainerHighest),
            _buildInfoRow(Icons.email_outlined, email.isNotEmpty ? email : "Not provided"),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkSurfaceContainerHighest),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Contact Information Locked',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock to view mobile number and email',
            style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleUnlock(context, ref),
              icon: const Icon(Icons.bolt_rounded, size: 20),
              label: const Text('Unlock with 1 Credit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          creditsAsync.when(
            data: (data) {
              final balance = data?['balance'] ?? 0;
              final freeUsed = data?['freeCreditsUsed'] ?? 0;
              final freeLimit = data?['freeLimit'] ?? 5;
              final bool hasFree = freeUsed < freeLimit;

              return Text(
                hasFree 
                  ? 'You have ${freeLimit - freeUsed} free credits remaining' 
                  : 'Your Balance: $balance Credits',
                style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (__, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
