import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';

class VerificationSuccessScreen extends ConsumerWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isEmployer = user?.role == 'employer';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ── Central Dynamic Graphic ──────────────────
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer faint ring
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFBFDBFE).withValues(alpha: 0.5), width: 1),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2.seconds, curve: Curves.easeInOut)
                       .fadeOut(duration: 2.seconds),

                      // Middle ring
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF6EE7B7).withValues(alpha: 0.8), width: 1.5),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.5.seconds, curve: Curves.easeInOut),

                      // Core green circle
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.check_rounded, color: Colors.white, size: 70),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut)
                       .shimmer(delay: 800.ms, duration: 1.5.seconds),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              const Text(
                'Verification Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
              ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 16),
              
              Text(
                isEmployer 
                  ? 'Your identity is verified. You can now post jobs and hire skilled workers instantly.'
                  : 'Congratulations! Your profile is now verified. You have earned the "Verified Karigar" badge.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), height: 1.6),
              ).animate().fadeIn(delay: 500.ms).moveY(begin: 10, end: 0),

              const SizedBox(height: 40),

              // ── Verified Badge Card ──────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 30),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Badge Active',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Trust score increased by 40%',
                            style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),

              const Spacer(),

              // ── Action Button ────────────────────────────
              SizedBox(
                width: double.infinity,
                child: Hero(
                  tag: 'auth_button',
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEmployer) {
                        context.go('/employer/dashboard');
                      } else {
                        context.go('/worker/dashboard');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A56DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xFF1A56DB).withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'Go to Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1.seconds).moveY(begin: 30, end: 0),

              const SizedBox(height: 24),
              
              const Text(
                'BHARAT KARIGAR • PREMIUM NETWORK',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ).animate().fadeIn(delay: 1.2.seconds),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

