import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view notifications.')),
      );
    }

    final notificationsAsync = ref.watch(userNotificationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationsAsync.maybeWhen(
            data: (notifications) {
              final hasUnread = notifications.any((notification) {
                return !notification.isRead;
              });

              if (!hasUnread) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () {
                  ref
                      .read(notificationRepositoryProvider)
                      .markAllAsRead(user.uid);
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
            orElse: () {
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _NotificationError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(userNotificationsProvider(user.uid));
            },
          );
        },
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _EmptyNotifications();
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.refresh(userNotificationsProvider(user.uid).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return _NotificationCard(
                  notification: notification,
                  formattedDate: formatDate(notification.createdAt),
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(notificationRepositoryProvider)
                          .markAsRead(notification.id);
                    }
                  },
                  onDelete: () {
                    ref
                        .read(notificationRepositoryProvider)
                        .deleteNotification(notification.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification deleted.')),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.formattedDate,
    required this.onTap,
    required this.onDelete,
  });

  IconData getNotificationIcon() {
    final message = notification.message.toLowerCase();

    if (message.contains('accepted')) {
      return Icons.check_circle_outline_rounded;
    }

    if (message.contains('rejected')) {
      return Icons.cancel_outlined;
    }

    if (message.contains('interview')) {
      return Icons.groups_outlined;
    }

    if (message.contains('review')) {
      return Icons.hourglass_top_rounded;
    }

    return Icons.notifications_outlined;
  }

  Color getNotificationColor() {
    final message = notification.message.toLowerCase();

    if (message.contains('accepted')) {
      return Colors.green;
    }

    if (message.contains('rejected')) {
      return Colors.red;
    }

    if (message.contains('interview')) {
      return Colors.purple;
    }

    if (message.contains('review')) {
      return Colors.orange;
    }

    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = notification.isRead
        ? isDarkMode
              ? AppColors.darkCard
              : Colors.white
        : AppColors.primaryBlue.withOpacity(isDarkMode ? 0.18 : 0.07);

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final notificationColor = getNotificationColor();

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDelete();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 13),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: notification.isRead
                    ? Colors.black.withOpacity(0.05)
                    : notificationColor.withOpacity(0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 49,
                  width: 49,
                  decoration: BoxDecoration(
                    color: notificationColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(getNotificationIcon(), color: notificationColor),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w700
                                    : FontWeight.w900,
                              ),
                            ),
                          ),

                          if (!notification.isRead)
                            Container(
                              height: 9,
                              width: 9,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        notification.message,
                        style: TextStyle(color: mutedTextColor, height: 1.4),
                      ),

                      if (notification.opportunityTitle.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          notification.opportunityTitle,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],

                      const SizedBox(height: 9),

                      Text(
                        formattedDate,
                        style: TextStyle(color: mutedTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 78,
              color: AppColors.mutedText,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(
              'Application updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotificationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
