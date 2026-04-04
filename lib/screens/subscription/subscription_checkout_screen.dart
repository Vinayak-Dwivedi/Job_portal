import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/subscription_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionCheckoutScreen extends ConsumerStatefulWidget {
  final String tier;
  final String priceStr;

  const SubscriptionCheckoutScreen({
    super.key,
    required this.tier,
    required this.priceStr,
  });

  @override
  ConsumerState<SubscriptionCheckoutScreen> createState() => _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState extends ConsumerState<SubscriptionCheckoutScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // No Razorpay service needed
  }

  Future<void> _processSubscription() async {
    setState(() => _isProcessing = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final days = widget.tier == 'pro' ? 30 : 90;
      final maxApp = widget.tier == 'pro' ? 10 : 999;
      await SubscriptionService.updateSubscription(uid, widget.tier, days, maxApp);
      if (mounted) {
        context.go('/subscription-success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscription update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _startPayment() {
    // Directly process subscription without payment gateway
    _processSubscription();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('${widget.tier.toUpperCase()} Plan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                       Text(widget.priceStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                     ],
                   ),
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 16.0),
                     child: Divider(color: Color(0xFFE2E8F0)),
                   ),
                   const Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Total Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                       Text('₹0 Due Now (Test)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                     ],
                   ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay Securely', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
        ],
        ),
      ),
    );
  }
}
