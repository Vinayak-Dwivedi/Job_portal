import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  String _role = 'worker';
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  List<String> _selectedSkills = [];
  List<Map<String, dynamic>> _documents = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    try {
      // 1. Fetch Job Categories
      final catsSnapshot = await FirebaseFirestore.instance.collection('job_categories').where('isActive', isEqualTo: true).get();
      _availableCategories = catsSnapshot.docs.map((d) => d['name'] as String).toList();

      // 2. Fetch User Profile
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(auth.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _role = data['role'] ?? 'worker';
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        
        final loc = data['location'];
        if (loc is Map<String, dynamic>) {
          _addressController.text = loc['address'] ?? '';
        }
        
        if (_role == 'worker') {
          _experienceController.text = (data['experience'] ?? 0).toString();
          final skillsList = data['skills'];
          if (skillsList is List) {
            _selectedSkills = List<String>.from(skillsList);
          }
        }

        final docsList = data['documents'];
        if (docsList is List) {
          _documents = List<Map<String, dynamic>>.from(docsList);
        }
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authProvider);
    if (auth == null) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': {
          'address': _addressController.text.trim(),
        },
        'documents': _documents,
      };

      if (_role == 'worker') {
        updateData['experience'] = int.tryParse(_experienceController.text) ?? 0;
        updateData['skills'] = _selectedSkills;
      }

      await FirebaseFirestore.instance.collection('users').doc(auth.uid).update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint("Error updating Profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating profile'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showAddDocumentDialog() {
    final docNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Add Document', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: TextField(
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Document Name',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = docNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _documents.add({'name': name, 'url': ''});
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController, theme, isRequired: true),
              const SizedBox(height: 16),
              _buildTextField('Bio', _bioController, theme, maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField('Address', _addressController, theme),
              const SizedBox(height: 16),
              
              if (_role == 'worker') ...[
                _buildTextField('Experience (Years)', _experienceController, theme, isNumber: true),
                const SizedBox(height: 16),
                Text('Skills', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableCategories.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return ChoiceChip(
                      label: Text(skill, style: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent)),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSkills.add(skill);
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ] else ...[
                 const SizedBox(height: 8), // For employer we omit skills & experience
              ],

              // Documents Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Documents', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _showAddDocumentDialog,
                    icon: Icon(Icons.add, color: theme.colorScheme.primary, size: 18),
                    label: Text('Add Document', style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_documents.isEmpty)
                Text('No documents added yet.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(doc['name'] ?? '', style: const TextStyle(color: Colors.white)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _documents.removeAt(index);
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ThemeData theme, {bool isRequired = false, bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: theme.colorScheme.onSurface),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          } : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
