import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../providers/theme_provider.dart';

class EmployerProfileScreen extends ConsumerWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employer = ref.watch(employerProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/employer/dashboard');
            }
          },
        ),
        title: Text(
          (employer?.companyName != null && employer!.companyName.isNotEmpty) 
              ? employer.companyName 
              : 'The Digital Atelier',
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () {
               showModalBottomSheet(
                 context: context,
                 backgroundColor: theme.cardColor,
                 shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                 builder: (context) => SafeArea(
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       ListTile(
                         leading: const Icon(Icons.logout, color: Colors.redAccent),
                         title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                         onTap: () {
                           Navigator.pop(context); // close sheet
                           authNotifier.logout();
                         },
                       )
                     ],
                   ),
                 )
               );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info Header
            _buildProfileHeader(employer, theme),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context, theme),
            const SizedBox(height: 24),

            // Statistics
            _buildStatisticsCards(theme),
            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(employer, theme),
            const SizedBox(height: 24),

            // Active Jobs Section
            _buildActiveJobsSection(theme),
            const SizedBox(height: 24),

            // Documents Section
            _buildDocumentsSection(theme),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(EmployerProfile? employer, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: (employer?.profilePhotoUrl != null && employer!.profilePhotoUrl!.isNotEmpty)
                    ? NetworkImage(employer.profilePhotoUrl!)
                    : null,
                child: (employer?.profilePhotoUrl == null || employer!.profilePhotoUrl!.isEmpty)
                    ? Text(
                        (employer?.companyName != null && employer!.companyName.isNotEmpty) 
                            ? employer.companyName.substring(0, 2).toUpperCase() 
                            : 'RA',
                        style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          (employer?.name != null && employer!.name.isNotEmpty) 
              ? employer.name 
              : 'Rajesh Construction',
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'CIVIL CONSTRUCTION',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text('4.9', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 6),
            Text('(156 ratings)', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
            ),
            Icon(Icons.location_on, color: theme.colorScheme.onSurfaceVariant, size: 14),
            const SizedBox(width: 4),
            Text('Mumbai, MH', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.explore, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Discover\nWorkers', textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, height: 1.2)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              context.push('/edit-profile');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: theme.colorScheme.outline, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: theme.colorScheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Edit Profile', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('ACTIVE POSTS', '12', theme)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('WORKERS HIRED', '45', theme)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(EmployerProfile? employer, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('About', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: const Text('View Portfolio', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
            )
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
             color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(employer?.name != null && employer!.name.isNotEmpty) ? employer.name : "Rajesh Construction"} has been a cornerstone of urban development in Western India for over 15 years. Specialized in large-scale residential complexes and industrial infrastructure, we pride ourselves on precision engineering and fostering a skilled workforce environment. Our current portfolio includes the Metro-Link bridge expansion and the Sapphire Towers project.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveJobsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Jobs', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text('See All', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onSurfaceVariant, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildJobCard(
          title: 'Master Carpenter',
          badgeText: 'URGENT',
          badgeColor: const Color(0xFFD97706), // Orange
          type: 'Full-time',
          salary: '₹28k - 35k',
          applicants: 42,
          avatarOffset: true,
          theme: theme,
        ),
        _buildJobCard(
          title: 'Industrial Electrician',
          badgeText: 'HIRING',
          badgeColor: const Color(0xFF10B981), // Green
          type: 'Contract',
          salary: '₹32k - 40k',
          applicants: 12,
          avatarOffset: false,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildJobCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required String type,
    required String salary,
    required int applicants,
    required bool avatarOffset,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, color: theme.colorScheme.onSurfaceVariant, size: 14),
              const SizedBox(width: 4),
              Text(type, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.payments_outlined, color: theme.colorScheme.onSurfaceVariant, size: 14),
              const SizedBox(width: 4),
              Text(salary, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
                    ),
                    if (avatarOffset)
                      const Positioned(
                        left: 16,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blueAccent,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
                        ),
                      ),
                    Positioned(
                      left: avatarOffset ? 32 : 16,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.outline,
                        child: const Text('+8', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Text('$applicants Applicants', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documents', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDocCard('GST Registration', 'Last verified: Oct 2023', theme),
        _buildDocCard('Business License', 'Valid until Dec 2025', theme),
      ],
    );
  }

  Widget _buildDocCard(String title, String subtitle, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
               color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.description, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
        ],
      ),
    );
  }
}
