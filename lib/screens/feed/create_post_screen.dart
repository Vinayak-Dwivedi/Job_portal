import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/post_service.dart';
import '../../widgets/feed/post_pending_banner.dart';
import '../../providers/worker_provider.dart';
import '../../providers/employer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unified schema supports 1 image per post')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  Future<void> _pickCamera() async {
    if (_selectedImages.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unified schema supports 1 image per post')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _submitPost() async {
    final desc = _descController.text.trim();

    if (desc.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text or an image to post!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authProvider);
      if (auth == null) throw Exception("User not logged in");

      final isWorker = auth.role == 'worker';
      
      String name = 'Unknown User';
      String? photoUrl;
      bool isVerified = false;

      if (isWorker) {
        final worker = ref.read(workerProvider);
        name = worker?.name ?? 'Worker';
        photoUrl = worker?.profilePhotoUrl;
        isVerified = worker?.isVerified ?? false;
      } else {
        final employer = ref.read(employerProvider);
        name = employer?.name ?? 'Employer';
        photoUrl = employer?.profilePhotoUrl;
        isVerified = employer?.isVerified ?? false;
      }

      await PostService.createPost(
        uid: auth.uid,
        name: name,
        role: auth.role,
        text: desc,
        imageFiles: _selectedImages,
        profilePhotoUrl: photoUrl,
        isVerified: isVerified,
        location: 'Current Location', // Placeholder or fetch actual location
      );

      if (mounted) {
        context.pop();
        // showPostPendingBanner(context); // Optional: if we want a banner
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish post: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isWorker = auth?.role == 'worker';
    
    String name = 'User';
    String? photoUrl;
    if (isWorker) {
      name = ref.watch(workerProvider)?.name ?? 'Worker';
      photoUrl = ref.watch(workerProvider)?.profilePhotoUrl;
    } else {
      name = ref.watch(employerProvider)?.name ?? 'Employer';
      photoUrl = ref.watch(employerProvider)?.profilePhotoUrl;
    }

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Post', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Post', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.darkSurfaceContainerHighest,
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white70)
                          : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.public, size: 12, color: AppColors.darkOnSurfaceVariant),
                                const SizedBox(width: 4),
                                const Text('Public', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                                const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.darkOnSurfaceVariant),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _descController,
                    maxLines: null,
                    minLines: 5,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'What do you want to talk about?',
                      hintStyle: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 18),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Image.file(_selectedImages.first, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.clear()),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          /// ── Bottom Toolbar ────────────────────────────
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              left: 16,
              right: 16,
              top: 8,
            ),
            decoration: const BoxDecoration(
              color: AppColors.darkSurfaceContainer,
              border: Border(top: BorderSide(color: AppColors.darkSurfaceContainerHighest, width: 0.5)),
            ),
            child: Row(
              children: [
                _buildToolbarItem(Icons.image_outlined, 'Photo', _pickImages),
                _buildToolbarItem(Icons.camera_alt_outlined, 'Video', _pickCamera),
                _buildToolbarItem(Icons.event_outlined, 'Event', () {}),
                _buildToolbarItem(Icons.more_horiz, '', () {}),
                const Spacer(),
                const Icon(Icons.mode_comment_outlined, color: AppColors.darkOnSurfaceVariant),
                const SizedBox(width: 4),
                const Text('Anyone', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarItem(IconData icon, String label, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: AppColors.darkOnSurfaceVariant, size: 24),
      onPressed: onTap,
      tooltip: label,
    );
  }
}
