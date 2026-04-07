import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final String location;
  final String latitude;
  final String longitude;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.role,
    this.name = '',
    this.company = '',
    this.skill = '',
    this.experience = '',
    this.location = '',
    this.latitude = '0',
    this.longitude = '0',
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

  if (otp.length == 4) {
    setState(() => _isVerifying = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final uid = 'uid_${widget.phone.replaceAll(RegExp(r'\D'), '')}';

    try {
      // ✅ SAVE TO FIRESTORE (UNIFIED SERVICE) - Ensure this completes BEFORE redirecting
      await FirestoreService.saveUser(uid, {
        'name': widget.name,
        'phone': widget.phone,
        'role': widget.role,
        'companyName': widget.company,
        'skills': widget.role == 'worker' ? [widget.skill] : [],
        'experience': int.tryParse(widget.experience) ?? 0,
        'location': widget.location,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
      });

      // 🔐 LOGIN (local state) - Move entry after Firestore success
      ref.read(authProvider.notifier).loginWithUid(
        uid,
        widget.phone,
        widget.role,
      );
    } catch (e) {
      debugPrint("❌ Firestore error: $e");
    }

    // 🔄 Update local providers
    if (widget.role == 'worker') {
      ref.read(workerProvider.notifier).updateFromSignup(
        uid: uid,
        name: widget.name,
        phone: widget.phone,
        skill: widget.skill,
        experience: widget.experience,
      );
    } else {
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
        content: Text('Invalid OTP'),
        backgroundColor: Colors.red,
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
      width: 64,
      height: 72,
      textStyle: TextStyle(
        fontSize: 28,
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: theme.colorScheme.primary, width: 2), // Branding blue highlight
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.35), // Soft glow
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Security Check',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Your',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                ).animate().fadeIn(duration: 500.ms).moveY(begin: 10, end: 0),
                Text(
                  'Identity',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary, // Themed primary color
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0)
                 .shimmer(duration: 2.seconds, delay: 1.seconds),
                const SizedBox(height: 16),
                Text(
                  "We've sent a secure code to your device. Enter the digits below to authenticate.",
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurfaceVariant, // Use themed secondary
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 48),
                
                // OTP Input
                Center(
                  child: Pinput(
                    length: 4,
                    controller: _pinController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (_) => _isVerifying ? null : _verifyOtp(),
                  ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),
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
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 3,
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.fingerprint, color: theme.colorScheme.primary, size: 24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AUTHORIZING...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    ),
                    child: const Text('Verify Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ).animate().fadeIn(delay: 700.ms).moveY(begin: 10, end: 0),
                ),
                const SizedBox(height: 24),
                
                // Resend text
                Center(
                  child: InkWell(
                    onTap: _canResend ? () {
                      // Logic to resend OTP
                    } : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          color: _canResend ? const Color(0xFFE5E7EB) : const Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: _canResend ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Verification',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Protecting your professional data is our top priority. Two-factor authentication keeps your profile safe.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 900.ms).moveY(begin: 10, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
