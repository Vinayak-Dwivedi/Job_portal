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
  return Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Your Profile",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),

            const SizedBox(height: 8),

            const Text(
              "Tell us about your professional expertise and basic details to get started.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // 🔹 Profile Photo Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withAlpha(50)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile Photo",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Clear photo helps in getting more work",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 PERSONAL INFO
            const Text(
              "Personal Information",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: "Full Name",
              hintText: "Enter your full name",
              controller: _nameController,
              validator: (val) => val == null || val.isEmpty ? "Full name is required" : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: "Mobile Number",
              hintText: "Enter your mobile number",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.isEmpty) return "Mobile number is required";
                if (val.length < 10) return "Enter a valid mobile number";
                return null;
              },
            ),

            // 🔹 WORK DETAILS
            const SizedBox(height: 24),
            const Text("Work Details",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            // Skill dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton(
                dropdownColor: const Color(0xFF1E293B),
                value: _skillController.text.isEmpty
                    ? "Carpenter"
                    : _skillController.text,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: ["Carpenter", "Electrician", "Plumber"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _skillController.text = val!;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Experience stepper
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      int val = int.tryParse(_expController.text) ?? 0;
                      if (val > 0) {
                        val--;
                        _expController.text = val.toString();
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  Column(
                    children: [
                      Text(
                        _expController.text.isEmpty
                            ? "0"
                            : _expController.text,
                        style: const TextStyle(
                            fontSize: 20, color: Colors.white),
                      ),
                      const Text("YEARS",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      int val = int.tryParse(_expController.text) ?? 0;
                      val++;
                      _expController.text = val.toString();
                      setState(() {});
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 BUTTON
            PrimaryButton(
              label: "Continue to Verification",
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    ),
  );
}
  // Removed unused _inputField helper
}