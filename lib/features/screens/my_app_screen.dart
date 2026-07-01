import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Track Your Applications',
              style: TextStyle(
                color: textColor,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Follow the progress of opportunities you applied for.',
              style: TextStyle(color: AppColors.mutedText),
            ),

            const SizedBox(height: 24),

            const _ApplicationCard(
              role: 'Flutter Development Intern',
              startup: 'AfriTech Solutions',
              status: 'Under Review',
              statusColor: Colors.orange,
              appliedDate: 'Applied on June 29, 2026',
            ),

            const _ApplicationCard(
              role: 'Digital Marketing Intern',
              startup: 'Impact Media Lab',
              status: 'Shortlisted',
              statusColor: Colors.green,
              appliedDate: 'Applied on June 25, 2026',
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String role;
  final String startup;
  final String status;
  final Color statusColor;
  final String appliedDate;

  const _ApplicationCard({
    required this.role,
    required this.startup,
    required this.status,
    required this.statusColor,
    required this.appliedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(startup, style: const TextStyle(color: AppColors.mutedText)),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                appliedDate,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
