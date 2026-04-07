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

    if (employer == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Dynamic data
    final companyName = employer.companyName.isNotEmpty ? employer.companyName : 'Company Name';
    final businessType = employer.businessType.isNotEmpty ? employer.businessType : 'Business Type';
    final bio = employer.bio;
    final rating = employer.rating > 0 ? employer.rating.toStringAsFixed(1) : 'New';
    final reviews = employer.reviewCount;
    final officeAddress = employer.officeAddress.isNotEmpty ? employer.officeAddress : 'Address not set';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/employer/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.colorScheme.onSurface),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
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
                         leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
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
        child: Column(
          children: [
            // Premium Header with Background Gradient
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.1),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            backgroundImage: (employer.logoUrl != null && employer.logoUrl!.isNotEmpty)
                                ? NetworkImage(employer.logoUrl!)
                                : null,
                            child: (employer.logoUrl == null || employer.logoUrl!.isEmpty)
                                ? Text(
                                    companyName.isNotEmpty ? companyName.substring(0, 1).toUpperCase() : 'E',
                                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                        if (employer.isVerified)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    companyName,
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      businessType.toUpperCase(),
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber[600], size: 18),
                      const SizedBox(width: 4),
                      Text(rating, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 4),
                      Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 4),
                      Text('$reviews Ratings', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_rounded, color: theme.colorScheme.onSurfaceVariant, size: 14),
                      const SizedBox(width: 4),
                      Text(officeAddress.split(',').last.trim(), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {}, // Action to find workers
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Find Workers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/edit-profile'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                            side: BorderSide(color: theme.colorScheme.outline),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '12',
                          label: 'ACTIVE POSTS',
                          theme: theme,
                          valueColor: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          value: '45',
                          label: 'WORKERS HIRED',
                          theme: theme,
                          valueColor: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // About Section
                  _SectionHeader(title: 'About Company', theme: theme),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                    ),
                    child: Text(
                      bio.isNotEmpty ? bio : 'No description provided yet. Add your company profile to attract more professional workers.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Jobs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(title: 'Active Jobs', theme: theme),
                      TextButton(
                        onPressed: () {},
                        child: Text('See All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _JobCard(
                    title: 'Master Carpenter',
                    type: 'Full-time',
                    salary: '₹28k - 35k',
                    applicants: 42,
                    theme: theme,
                    isUrgent: true,
                  ),
                  _JobCard(
                    title: 'Industrial Electrician',
                    type: 'Contract',
                    salary: '₹32k - 40k',
                    applicants: 12,
                    theme: theme,
                    isUrgent: false,
                  ),
                  const SizedBox(height: 24),

                  // Documents Section
                  _SectionHeader(title: 'Verified Documents', theme: theme),
                  const SizedBox(height: 12),
                  _DocCard(title: 'GST Registration', theme: theme),
                  _DocCard(title: 'Business License', theme: theme),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;
  final Color valueColor;

  const _StatCard({required this.value, required this.label, required this.theme, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String type;
  final String salary;
  final int applicants;
  final ThemeData theme;
  final bool isUrgent;

  const _JobCard({required this.title, required this.type, required this.salary, required this.applicants, required this.theme, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('URGENT', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.work_history_outlined, color: theme.colorScheme.onSurfaceVariant, size: 14),
              const SizedBox(width: 6),
              Text(type, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.currency_rupee_rounded, color: theme.colorScheme.onSurfaceVariant, size: 14),
              const SizedBox(width: 4),
              Text(salary, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$applicants Applicants', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.onSurfaceVariant, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _DocCard({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: theme.colorScheme.secondary, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.check_circle_rounded, color: Colors.green.shade400, size: 18),
        ],
      ),
    );
  }
}
