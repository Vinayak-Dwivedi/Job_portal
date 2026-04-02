import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// Mock Auth Notifier — replace with FirebaseAuth stream later
class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  void login(String phone, String role) {
    state = UserModel(
      uid: 'mock_uid_${phone.replaceAll(' ', '')}',
      phone: phone,
      role: role,
      isVerified: true,
      isProfileComplete: true,
      createdAt: DateTime.now(),
    );
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider)?.role;
});
