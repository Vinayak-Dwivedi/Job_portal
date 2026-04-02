import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';

class WorkerSignupScreen extends ConsumerStatefulWidget {
  const WorkerSignupScreen({super.key});

  @override
  ConsumerState<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends ConsumerState<WorkerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillController = TextEditingController();
  final _expController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.push('/otp', extra: {
        'phone': _phoneController.text.trim(),
        'role': 'worker',
        'name': _nameController.text.trim(),
        'skill': _skillController.text.trim(),
        'experience': _expController.text.trim(),
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _skillController.dispose();
    _expController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let\'s get you set up.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about your skills to find the best jobs.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Avatar Placeholder
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      child: Icon(Icons.person_outline, size: 50, color: AppColors.outline),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                label: 'Full Name',
                hintText: 'e.g. Rahul Sharma',
                prefixIcon: const Icon(Icons.person_outline),
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Full Name is required' : null,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Phone Number',
                hintText: '+91 99999 99999',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                controller: _phoneController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Phone Number is required';
                  if (val.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Primary Skill',
                hintText: 'e.g. Electrician, Welder',
                prefixIcon: const Icon(Icons.build_outlined),
                controller: _skillController,
                validator: (val) => val == null || val.isEmpty ? 'Primary Skill is required' : null,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Experience (Years)',
                hintText: 'e.g. 5',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.history_outlined),
                controller: _expController,
                validator: (val) => val == null || val.isEmpty ? 'Experience is required' : null,
              ),

              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Send OTP',
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
