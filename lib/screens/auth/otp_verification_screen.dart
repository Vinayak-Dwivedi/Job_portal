import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/employer_provider.dart';
import '../../core/services/firestore_service.dart';



class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final String role;
  final String name;
  final String company;
  final String skill;
  final String experience;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.role,
    this.name = '',
    this.company = '',
    this.skill = '',
    this.experience = '',
  });



  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Simulate initial delay before allowing resend
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  bool _isVerifying = false;

 void _verifyOtp() async {
  final otp = _pinController.text;

  if (otp == '1234' || otp.length == 4) {
    setState(() => _isVerifying = true);

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 🔹 Generate consistent mock UID
    final uid = 'uid_${widget.phone.replaceAll(RegExp(r'\D'), '')}';

    // 🔹 Login
    ref.read(authProvider.notifier).loginWithUid(uid, widget.phone, widget.role);

    // 🔥 SAVE TO FIRESTORE (NEW)
    if (widget.role == 'employer') {
      try {
        await FirestoreService.saveEmployer(uid, {
          'name': widget.name,
          'phone': widget.phone,
          'company': widget.company,
        });
      } catch (e) {
        debugPrint("❌ Error saving employer: $e");
      }
    }

    // 🔹 Existing local state update
    if (widget.role == 'worker') {
      ref.read(workerProvider.notifier).updateFromSignup(
        uid: uid,
        name: widget.name,
        phone: widget.phone,
        skill: widget.skill,
        experience: widget.experience,
      );
    } else if (widget.role == 'employer') {
      ref.read(employerProvider.notifier).updateFromSignup(
        uid: uid,
        contactName: widget.name,
        companyName: widget.company,
        phone: widget.phone,
      );
    }

    context.go('/verified');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid OTP. Please enter 4 digits.'),
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
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 72,
      textStyle: const TextStyle(
        fontSize: 28,
        color: Color(0xFF111827), // Always dark text for OTP boxes
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF000839), width: 2),
      ),
    );

    // Image 1 style is light layout
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // light gray background from image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000839)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Verify Your Account',
          style: TextStyle(
            color: Color(0xFF000839),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'The Kinetic Professional',
                style: TextStyle(
                  color: Color(0xFF000839),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headings
              const Text(
                'Verify Your',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF000839),
                  height: 1.1,
                ),
              ),
              const Text(
                'Identity',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF9E5E00), // Golden brown
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We've sent a code to your phone. Enter the digits below to access your career dashboard.",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // OTP Input
              Center(
                child: Pinput(
                  length: 4,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onCompleted: (_) => _isVerifying ? null : _verifyOtp(),
                ),
              ),
              const SizedBox(height: 48),
              
              // Verifying Indicator
              if (_isVerifying)
                Center(
                  child: Column(
                    children: [
                      Animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                        effects: [
                          ScaleEffect(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: 800.ms,
                            curve: Curves.easeInOut,
                          ),
                          FadeEffect(
                            begin: 0.8,
                            end: 1.0,
                            duration: 800.ms,
                            curve: Curves.easeInOut,
                          ),
                        ],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF9E5E00).withValues(alpha: 0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9E5E00).withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                color: Color(0xFF9E5E00),
                                strokeWidth: 3,
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8EEFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fingerprint, color: Color(0xFF1D4ED8), size: 24),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'VERIFYING...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF000839),
                        ),
                      ),
                    ],
                  ),
                )

              else
                const SizedBox(height: 90), // Placeholder to maintain space

              const SizedBox(height: 32),

              // Verify Code Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000839),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Verify Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Resend text
              Center(
                child: InkWell(
                  onTap: _canResend ? () {
                    // Logic to resend OTP
                  } : null,
                  child: Text(
                    "Didn't receive the code?",
                    style: TextStyle(
                      color: _canResend ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Secure Verification Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E7FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: Color(0xFF000839), size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure Verification',
                            style: TextStyle(
                              color: Color(0xFF000839),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Protecting your professional data is our top priority. Two-factor authentication keeps your profile safe.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
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
