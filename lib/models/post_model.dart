import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String userRole;
  final String userName;
  final String? userPhotoUrl;
  final bool isUserVerified;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String status;             // "pending" | "approved" | "rejected"
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final int likeCount;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userRole,
    required this.userName,
    this.userPhotoUrl,
    required this.isUserVerified,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.approvedAt,
    required this.likeCount,
  });

  factory PostModel.fromMap(Map<String, dynamic> data) => PostModel(
    postId: data['postId'] ?? '',
    userId: data['userId'] ?? '',
    userRole: data['userRole'] ?? '',
    userName: data['userName'] ?? '',
    userPhotoUrl: data['userPhotoUrl'],
    isUserVerified: data['isUserVerified'] ?? false,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    imageUrls: List<String>.from(data['imageUrls'] ?? []),
    status: data['status'] ?? 'pending',
    rejectionReason: data['rejectionReason'],
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
    likeCount: data['likeCount'] ?? 0,
  );
}
