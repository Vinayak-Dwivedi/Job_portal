import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker_model.dart';

class WorkerNotifier extends Notifier<WorkerModel?> {
  @override
  WorkerModel? build() => null;

  void updateFromSignup({
    required String name,
    required String phone,
    required String skill,
    required String experience,
  }) {
    state = WorkerModel(
      uid: 'mock_uid_${phone.replaceAll(' ', '')}',
      name: name.isNotEmpty ? name : 'Worker',
      phone: phone,
      isVerified: true,
      jobCategory: 'blue_collar',
      jobTitles: skill.isNotEmpty ? [skill] : [],
      skills: skill.isNotEmpty ? [skill] : [],
      location: 'India',
      credits: 20,
    );
  }

  void updateWorker(WorkerModel updated) {
    state = updated;
  }

  void updateName(String name) {
    if (state == null) return;
    state = state!.copyWith(name: name);
  }

  void updateSkills(List<String> skills) {
    if (state == null) return;
    state = state!.copyWith(skills: skills);
  }
}

final workerProvider = NotifierProvider<WorkerNotifier, WorkerModel?>(() => WorkerNotifier());
