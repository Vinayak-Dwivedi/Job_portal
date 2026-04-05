import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerProfile {
  final String uid;
  final String contactName;
  final String companyName;
  final String phone;
  final String? profilePhotoUrl;
  final String location;
  final bool isVerified;

  EmployerProfile({
    required this.uid,
    this.contactName = '',   // ✅ FIX
    this.companyName = '',   // ✅ FIX
    this.phone = '',         // ✅ FIX
    this.location = '',
    this.profilePhotoUrl,
    this.isVerified = false,
  });


  String get name => companyName.isNotEmpty ? companyName : contactName;

  EmployerProfile copyWith({
    String? uid,
    String? contactName,
    String? companyName,
    String? phone,
    String? location,
    String? profilePhotoUrl,
    bool? isVerified,
  }) {
    return EmployerProfile(
      uid: uid ?? this.uid,
      contactName: contactName ?? this.contactName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class EmployerNotifier extends Notifier<EmployerProfile?> {
  @override
  EmployerProfile? build() {
    return null;
  }

  void updateFromSignup({
    required String uid,
    required String contactName,
    required String companyName,
    required String phone,
  }) {
    state = EmployerProfile(
      uid: uid,
      contactName: contactName,
      companyName: companyName,
      phone: phone,
      isVerified: true,
    );
  }

  Future<void> loadProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        print("🔥 DATA FROM FIRESTORE: $data");
        state = EmployerProfile(
          uid: uid,
          contactName: (data['name'] ?? '').toString(),
          companyName: (data['companyName'] ?? data['company'] ?? '').toString(),
          phone: (data['phone'] ?? '').toString(),
          location: data['location'] is Map ? (data['location']['address'] ?? '').toString() : (data['location'] ?? '').toString(),
          profilePhotoUrl: (data['profilePhotoUrl'] ?? data['logoUrl'] ?? '').toString(),
          isVerified: true,
        );
      }
    } catch (e) {
      print("❌ Error loading employer profile: $e");
    }
  }
}

final employerProvider = NotifierProvider<EmployerNotifier, EmployerProfile?>(() => EmployerNotifier());
