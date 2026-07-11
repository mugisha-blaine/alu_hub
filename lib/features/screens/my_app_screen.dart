import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/application.dart';
import '../../../providers/application_provider.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Recently submitted';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your applications.')),
      );
    }

    final applicationsAsync = ref.watch(studentApplicationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        automaticallyImplyLeading: false,
      ),
      body: applicationsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _ApplicationsError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(studentApplicationsProvider(user.uid));
            },
          );
        },
        data: (applications) {
          if (applications.isEmpty) {
            return const _EmptyApplications();
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.refresh(studentApplicationsProvider(user.uid).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];

                return _ApplicationCard(
                  application: application,
                  formattedDate: formatDate(application.createdAt),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final String formattedDate;

  const _ApplicationCard({
    required this.application,
    required this.formattedDate,
  });

  Color getStatusColor() {
    switch (application.status.toLowerCase()) {
      case 'accepted':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'under review':
      case 'reviewing':
        return Colors.orange;

      case 'interview':
        return Colors.purple;

      default:
        return Colors.blue;
    }
  }

  IconData getStatusIcon() {
    switch (application.status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      case 'under review':
      case 'reviewing':
        return Icons.hourglass_top_rounded;

      case 'interview':
        return Icons.groups_outlined;

      default:
        return Icons.send_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final statusColor = getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.opportunityTitle,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      application.startupName,
                      style: TextStyle(color: mutedTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: mutedTextColor,
              ),

              const SizedBox(width: 6),

              Text(
                'Applied: $formattedDate',
                style: TextStyle(color: mutedTextColor, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(getStatusIcon(), color: statusColor, size: 18),

                const SizedBox(width: 6),

                Text(
                  application.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Divider(),

          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 10),
            title: const Text(
              'View application details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            children: [
              _DetailRow(label: 'Student name', value: application.studentName),

              _DetailRow(label: 'Email', value: application.studentEmail),

              _DetailRow(label: 'Phone', value: application.phone),

              _DetailRow(label: 'Study year', value: application.studyYear),

              if (application.portfolioUrl.isNotEmpty)
                _DetailRow(label: 'Portfolio', value: application.portfolioUrl),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Motivation',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  application.motivation.isEmpty
                      ? 'No motivation provided'
                      : application.motivation,
                  style: TextStyle(color: mutedTextColor, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(color: mutedTextColor, fontSize: 13),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyApplications extends StatelessWidget {
  const _EmptyApplications();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 76,
              color: AppColors.mutedText,
            ),

            const SizedBox(height: 16),

            Text(
              'No applications yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Applications you submit will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ApplicationsError({required this.message, required this.onRetry});

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
              'Unable to load applications',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedText),
            ),

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
