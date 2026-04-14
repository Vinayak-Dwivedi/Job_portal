import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Upgrade Pro', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('platform_settings').doc('subscriptions').snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic> prices = {
            'pro': '₹299',
            'elite': '₹799',
          };

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data['proPrice'] != null) prices['pro'] = data['proPrice'];
            if (data['elitePrice'] != null) prices['elite'] = data['elitePrice'];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.star, color: Color(0xFFF59E0B), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Get Discovered Faster',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a plan that fits your career goals.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildPlanCard(
                  context,
                  tier: 'pro',
                  name: 'Pro Plan',
                  price: prices['pro']!,
                  duration: '/mo',
                  features: [
                    'Unlimited Job Applications',
                    'Priority Profile Listing',
                    'Contact Employers Directly',
                    'No Ads',
                  ],
                  color: const Color(0xFF1D4ED8),
                  isPopular: true,
                ),
                const SizedBox(height: 20),
                
                _buildPlanCard(
                  context,
                  tier: 'elite',
                  name: 'Elite Plan',
                  price: prices['elite']!,
                  duration: '/quarter',
                  features: [
                    'Everything in Pro',
                    'Dedicated Account Manager',
                    'Featured Badge on Profile',
                    'Resume Feedback',
                  ],
                  color: const Color(0xFF0F172A),
                  isPopular: false,
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String tier,
    required String name,
    required String price,
    required String duration,
    required List<String> features,
    required Color color,
    required bool isPopular,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPopular ? color : const Color(0xFFE2E8F0), width: isPopular ? 2 : 1),
        boxShadow: [
          if (isPopular)
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
              ),
              child: const Text('MOST POPULAR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
                      child: Text(duration, style: const TextStyle(color: Color(0xFF64748B))),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(f, style: const TextStyle(color: Color(0xFF334155), fontSize: 14))),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/subscription-checkout', extra: {'tier': tier, 'priceStr': price});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Choose Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
