import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PostImageGrid extends StatelessWidget {
  final List<String> urls;

  const PostImageGrid({super.key, required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildGrid(context),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    switch (urls.length) {
      case 1:
        return _imageWidget(context, urls[0], 0, height: 220);
      case 2:
        return Row(
          children: [
            Expanded(child: _imageWidget(context, urls[0], 0, height: 180)),
            const SizedBox(width: 4),
            Expanded(child: _imageWidget(context, urls[1], 1, height: 180)),
          ],
        );
      case 3:
        return Row(
          children: [
            Expanded(child: _imageWidget(context, urls[0], 0, height: 220)),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  _imageWidget(context, urls[1], 1, height: 108),
                  const SizedBox(height: 4),
                  _imageWidget(context, urls[2], 2, height: 108),
                ],
              ),
            ),
          ],
        );
      default:
        // 4 or more
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _imageWidget(context, urls[0], 0, height: 140)),
                const SizedBox(width: 4),
                Expanded(child: _imageWidget(context, urls[1], 1, height: 140)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: _imageWidget(context, urls[2], 2, height: 140)),
                const SizedBox(width: 4),
                Expanded(child: _imageWidget(context, urls[3], 3, height: 140)),
              ],
            ),
          ],
        );
    }
  }

  Widget _imageWidget(BuildContext context, String url, int index, {required double height}) {
    return GestureDetector(
      onTap: () => _openGallery(context, index),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _openGallery(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoViewGallery.builder(
            itemCount: urls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(urls[index]),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: urls[index]),
              );
            },
            pageController: PageController(initialPage: initialIndex),
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
