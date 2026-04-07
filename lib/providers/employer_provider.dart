import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employer_model.dart';

class EmployerNotifier extends Notifier<EmployerModel?> {
  @override
  EmployerModel? build() {
    return null;
  }

  void updateFromSignup({
    required String uid,
    required String contactName,
    required String companyName,
    required String phone,
  }) {
    state = EmployerModel(
      uid: uid,
      contactPersonName: contactName,
      companyName: companyName,
      phone: phone,
      isVerified: true,
      businessType: '',
      officeAddress: '',
    );
  }

  Future<void> loadProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        print("🔥 DATA FROM FIRESTORE: $data");
        state = EmployerModel.fromMap(data, uid);
      } else {
        // 🆕 Handle new employer WITHOUT a document (fallback)
        print("ℹ️ Employer Profile document not found, initializing basic state");
        state = EmployerModel(
          uid: uid,
          contactPersonName: 'Employer',
          companyName: 'Company Name',
          phone: '',
          businessType: '',
          officeAddress: '',
          isVerified: true,
        );
      }
    } catch (e) {
      print("❌ Error loading employer profile: $e");
    }
  }
}

final employerProvider = NotifierProvider<EmployerNotifier, EmployerModel?>(() => EmployerNotifier());
