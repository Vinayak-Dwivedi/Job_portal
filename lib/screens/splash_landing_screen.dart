import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/primary_button.dart';

class SplashLandingScreen extends StatelessWidget {
  const SplashLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.handshake, color: Colors.white, size: 40),
                      ),
                    ),
                    Text(
                      'KI',
                      style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Earn Through Your Skills',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, left: 32, right: 32, bottom: 32),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, -10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Language selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('English', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => context.push('/role-select'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/role-select'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primary),
                          children: const [
                            TextSpan(text: 'I already have an account — '),
                            TextSpan(text: 'Log In', style: TextStyle(decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('TERMS & CONDITIONS', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.outline, letterSpacing: 1)),
                        Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.outlineVariant)),
                        Text('PRIVACY POLICY', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.outline, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('© 2024 KI Marketplace. All rights reserved.', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.outlineVariant, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

