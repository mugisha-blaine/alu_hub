import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/startup_verification.dart';
import '../repositories/admin_repo.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final startupVerificationProvider =
    StreamProvider<List<StartupVerificationModel>>((ref) {
      final repository = ref.watch(adminRepositoryProvider);

      return repository.watchStartupAccounts();
    });
