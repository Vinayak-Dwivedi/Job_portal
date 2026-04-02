import 'dart:io';

class WorkerModel {
  final String uid;
  final String name;
  final String? profilePhotoUrl;
  final File? localImageFile; // For unuploaded changes
  final String location;
  final String bio;
  final String jobCategory; // "blue_collar", "white_collar", "both"
  final List<String> jobTitles;
  final List<String> skills;
  // experience & education can be implemented later
  
  // From user collection
  final bool isVerified;
  final String phone;
  final String? email;
  final int credits;

  WorkerModel({
    required this.uid,
    required this.name,
    this.profilePhotoUrl,
    this.localImageFile,
    this.location = '',
    this.bio = '',
    this.jobCategory = 'blue_collar',
    this.jobTitles = const [],
    this.skills = const [],
    this.isVerified = false,
    required this.phone,
    this.email,
    this.credits = 0,
  });

  WorkerModel copyWith({
    String? uid,
    String? name,
    String? profilePhotoUrl,
    File? localImageFile,
    String? location,
    String? bio,
    String? jobCategory,
    List<String>? jobTitles,
    List<String>? skills,
    bool? isVerified,
    String? phone,
    String? email,
    int? credits,
  }) {
    return WorkerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      localImageFile: localImageFile ?? this.localImageFile,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      jobCategory: jobCategory ?? this.jobCategory,
      jobTitles: jobTitles ?? this.jobTitles,
      skills: skills ?? this.skills,
      isVerified: isVerified ?? this.isVerified,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      credits: credits ?? this.credits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'location': location,
      'bio': bio,
      'jobCategory': jobCategory,
      'jobTitles': jobTitles,
      'skills': skills,
      'isVerified': isVerified,
      'phone': phone,
      'email': email,
      'credits': credits,
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map, String uid) {
    return WorkerModel(
      uid: uid,
      name: map['name'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
      jobCategory: map['jobCategory'] ?? 'blue_collar',
      jobTitles: List<String>.from(map['jobTitles'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      isVerified: map['isVerified'] ?? false,
      phone: map['phone'] ?? '',
      email: map['email'],
      credits: map['credits'] ?? 0,
    );
  }
}
