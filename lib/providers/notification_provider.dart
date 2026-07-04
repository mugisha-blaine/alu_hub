import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import '../repositories/notification_repo.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final userNotificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
      final repository = ref.watch(notificationRepositoryProvider);

      return repository.watchNotifications(userId);
    });
