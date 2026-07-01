import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Recent Updates',
            style: TextStyle(
              color: textColor,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          const _NotificationTile(
            icon: Icons.check_circle_outline_rounded,
            title: 'Application received',
            message:
                'Your application for Flutter Development Intern was submitted.',
            time: '10 minutes ago',
            unread: true,
          ),
          const _NotificationTile(
            icon: Icons.star_outline_rounded,
            title: 'You were shortlisted',
            message: 'Impact Media Lab shortlisted your application.',
            time: '2 hours ago',
            unread: true,
          ),
          const _NotificationTile(
            icon: Icons.work_outline_rounded,
            title: 'New opportunity',
            message: 'A new UI/UX Design internship has been posted.',
            time: 'Yesterday',
            unread: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool unread;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: unread ? Border.all(color: AppColors.accentBlue) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              height: 9,
              width: 9,
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
