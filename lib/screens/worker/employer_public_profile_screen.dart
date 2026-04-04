import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADD THIS
import '../../widgets/subscription/subscription_gate_widget.dart';

class EmployerPublicProfileScreen extends StatelessWidget {
  final String employerId;
  const EmployerPublicProfileScreen({super.key, required this.employerId});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('employers')
          .doc(employerId)
          .get(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        // ✅ SAFE DATA (NO NULL ERROR)
        final employerName = (data?['companyName'] ?? '').toString();
        final contactName = (data?['name'] ?? '').toString();
        final phone = (data?['phone'] ?? '').toString();

        final displayName =
            employerName.isNotEmpty ? employerName : contactName;

        final employerLogoColor = const Color(0xFF1D4ED8);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              // ── HEADER ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF1D4ED8),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(displayName), // ✅ FIXED
                  background: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1D4ED8),
                              Color(0xFF1E40AF)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 24,
                        child: Transform.translate(
                          offset: const Offset(0, 40),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  employerLogoColor.withOpacity(0.1),
                              child: Icon(Icons.business_rounded,
                                  color: employerLogoColor, size: 50),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── INFO ──
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Phone: $phone",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Row(
                        children: [
                          _EmployerStat(
                              label: 'Active Jobs',
                              value: '12',
                              icon: Icons.work_rounded),
                          SizedBox(width: 24),
                          _EmployerStat(
                              label: 'Workers Hired',
                              value: '450+',
                              icon: Icons.people_rounded),
                          SizedBox(width: 24),
                          _EmployerStat(
                              label: 'Rating',
                              value: '4.8/5',
                              icon: Icons.star_rounded,
                              color: Colors.amber),
                        ],
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        'About Company',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),

                      const SizedBox(height: 12),

                      const SubscriptionGate(
                        featureName: 'Employer Details',
                        requiredTier: 'pro',
                        child: Text(
                          'This employer is hiring skilled workers. More details coming soon.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}

class _EmployerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _EmployerStat({
    required this.label,
    required this.value,
    required this.icon,
    this.color = const Color(0xFF1D4ED8),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label),
      ],
    );
  }
}