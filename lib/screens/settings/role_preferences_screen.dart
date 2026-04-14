import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class RolePreferencesScreen extends ConsumerWidget {
  const RolePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final isEmployer = user?.role == 'employer';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEmployer ? 'Recruitment Prefs' : 'Job Preferences', 
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: isEmployer ? _buildEmployerPrefs(theme) : _buildWorkerPrefs(theme),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerPrefs(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Job Availability', theme),
        const SizedBox(height: 12),
        _buildCard([
          _buildPreferenceTile(Icons.access_time_rounded, 'Work Schedule', 'Full-time / Part-time', theme),
          _buildPreferenceTile(Icons.map_outlined, 'Job Radius', 'Within 15km', theme),
          _buildPreferenceTile(Icons.payments_outlined, 'Expected Daily Rate', '₹800 - ₹1200', theme),
        ], theme),
        const SizedBox(height: 24),
        _buildSectionHeader('Trade Focus', theme),
        const SizedBox(height: 12),
        _buildCard([
          _buildPreferenceTile(Icons.construction_rounded, 'Primary Trade', 'Plumbing / Pipefitting', theme),
          _buildPreferenceTile(Icons.settings_suggest_outlined, 'Secondary Trade', 'General Maintenance', theme),
        ], theme),
      ],
    );
  }

  Widget _buildEmployerPrefs(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Hiring Strategy', theme),
        const SizedBox(height: 12),
        _buildCard([
          _buildPreferenceTile(Icons.speed_rounded, 'Hiring Speed', 'Urgent / Immediate', theme),
          _buildPreferenceTile(Icons.groups_outlined, 'Typical Team Size', '5 - 10 Workers', theme),
          _buildPreferenceTile(Icons.location_city_rounded, 'Project Location', 'Mumbai Metropolitan', theme),
        ], theme),
        const SizedBox(height: 24),
        _buildSectionHeader('Worker Requirements', theme),
        const SizedBox(height: 12),
        _buildCard([
          _buildPreferenceTile(Icons.verified_outlined, 'Preferred Experience', '3+ Years Professional', theme),
          _buildPreferenceTile(Icons.workspace_premium_outlined, 'Certification Level', 'Govt Certified Only', theme),
        ], theme),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPreferenceTile(IconData icon, String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), size: 18),
        ],
      ),
    );
  }
}
