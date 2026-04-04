import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';

class EmployerProfileScreen extends ConsumerWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employer = ref.watch(employerProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Employer Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (employer?.profilePhotoUrl != null && employer!.profilePhotoUrl!.isNotEmpty)
                        ? NetworkImage(employer.profilePhotoUrl!)
                        : const NetworkImage('https://ui-avatars.com/api/?name=Company&background=000839&color=fff'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    employer?.companyName ?? 'Company Name',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    employer?.contactName ?? 'Contact Person',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Settings List
            _buildSettingItem(Icons.business_rounded, 'Company Details', () {}),
            _buildSettingItem(Icons.notifications_none_rounded, 'Notifications', () {}),
            _buildSettingItem(Icons.security_rounded, 'Security & Password', () {}),
            _buildSettingItem(Icons.help_outline_rounded, 'Help & Support', () {}),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => authNotifier.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red.shade100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF1D4ED8)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
