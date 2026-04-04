import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';

class EmployerSignupScreen extends StatefulWidget {
  const EmployerSignupScreen({super.key});

  @override
  State<EmployerSignupScreen> createState() => _EmployerSignupScreenState();
}

class _EmployerSignupScreenState extends State<EmployerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.push('/otp', extra: {
        'phone': _phoneController.text.trim(),
        'role': 'employer',
        'name': _nameController.text.trim(),
        'company': _companyController.text.trim(),
        'skill': '',
        'experience': '',
      });

    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Employer Sign Up'),
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
                'Post Jobs & Find Talent',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your employer profile to start hiring.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Contact Name',
                hintText: 'e.g. Rajesh Kumar',
                prefixIcon: const Icon(Icons.person_outline),
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Company Name',
                hintText: 'e.g. Acme Corp',
                prefixIcon: const Icon(Icons.business_outlined),
                controller: _companyController,
                validator: (val) => val == null || val.isEmpty ? 'Company name is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Phone Number',
                hintText: '+91 99999 99999',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                controller: _phoneController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Phone is required';
                  if (val.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              PrimaryButton(label: 'Send OTP', onPressed: _submitForm),
            ],
          ),
        ),
      ),
    );
  }
}
