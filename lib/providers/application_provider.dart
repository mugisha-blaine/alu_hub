import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application.dart';
import '../repositories/application_repository.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

final studentApplicationsProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, studentId) {
      final repository = ref.watch(applicationRepositoryProvider);

      return repository.watchStudentApplications(studentId);
    });

final startupApplicationsProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, startupId) {
      final repository = ref.watch(applicationRepositoryProvider);

      return repository.watchStartupApplications(startupId);
    });
