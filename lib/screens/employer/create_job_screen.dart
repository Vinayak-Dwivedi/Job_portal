import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final wageController = TextEditingController();
  final durationController = TextEditingController();
  final workersController = TextEditingController();
  final locationController = TextEditingController();

  bool isLoading = false;

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('jobs').add({
        'uid': "uid_9999999999", // ⚠️ replace later with auth uid
        'title': titleController.text.trim(),
        'category': categoryController.text.trim(),
        'description': descriptionController.text.trim(),
        'wage': wageController.text.trim(),
        'duration': durationController.text.trim(),
        'workersNeeded': workersController.text.trim(),
        'location': locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Job Posted Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("❌ ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Job Post"),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _postJob,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Post", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: titleController,
                decoration: input("Job Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: categoryController,
                decoration: input("Category"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: input("Job Description"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: wageController,
                keyboardType: TextInputType.number,
                decoration: input("Daily Wage ₹"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: input("Duration (Days)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: workersController,
                keyboardType: TextInputType.number,
                decoration: input("Workers Needed"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: locationController,
                decoration: input("Location"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _postJob,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Post Job"),
              )
            ],
          ),
        ),
      ),
    );
  }
}