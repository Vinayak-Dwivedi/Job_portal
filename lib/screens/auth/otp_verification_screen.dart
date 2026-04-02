import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/common/otp_loading_overlay.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final String role;
  final String name;
  final String skill;
  final String experience;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.role,
    this.name = '',
    this.skill = '',
    this.experience = '',
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    for (int i = 60; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _resendSeconds = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() => _canResend = true);
  }

  bool _isVerifying = false;

  void _verifyOtp() async {
    final otp = _pinController.text;
    if (otp == '123456' || otp == '12345') {
      setState(() => _isVerifying = true);
      
      // Modern premium experience: simulated 3s verification delay
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted) return;

      // Log the user in via Riverpod
      ref.read(authProvider.notifier).login(widget.phone, widget.role);

      // Seed initial worker data
      if (widget.role == 'worker') {
        ref.read(workerProvider.notifier).updateFromSignup(
          name: widget.name,
          phone: widget.phone,
          skill: widget.skill,
          experience: widget.experience,
        );
      }

      context.go('/verified');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Use 123456.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: AppColors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4FE),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'Verify Your Number',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Icon graphic
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                          ),
                          child: const Icon(Icons.sms_outlined, color: AppColors.primary, size: 50),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'We sent a 6-digit OTP to',
                          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.phone.isNotEmpty ? widget.phone : '+91 98765 43210',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Change number',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Pinput(
                          length: 6,
                          controller: _pinController,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          onCompleted: (_) => _verifyOtp(),
                        ),
                        const SizedBox(height: 32),
                        _canResend
                            ? TextButton(
                                onPressed: () {
                                  setState(() => _canResend = false);
                                  _startTimer();
                                },
                                child: const Text('Resend OTP', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              )
                            : Text(
                                'Resend OTP in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                              ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isVerifying ? null : _verifyOtp,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: const Color(0xFF1A56DB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Verify & Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isVerifying) const OtpLoadingOverlay(),
        ],
      ),
    );
  }
}
