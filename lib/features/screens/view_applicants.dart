import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../models/application.dart';
import '../../../providers/application_provider.dart';

class ViewApplicantsScreen extends ConsumerWidget {
  const ViewApplicantsScreen({super.key});

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void updateStatus({
    required BuildContext context,
    required WidgetRef ref,
    required ApplicationModel application,
    required String status,
  }) {
    ref
        .read(applicationRepositoryProvider)
        .updateApplicationStatus(applicationId: application.id, status: status)
        .then((_) {
          if (!context.mounted) {
            return;
          }

          showMessage(context, 'Application status changed to $status.');
        })
        .catchError((error) {
          if (!context.mounted) {
            return;
          }

          showMessage(context, 'Unable to update application: $error');
        });
  }

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
        body: Center(child: Text('Please sign in to view applicants.')),
      );
    }

    final applicationsAsync = ref.watch(startupApplicationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('View Applicants')),
      body: applicationsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _ApplicantsError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(startupApplicationsProvider(user.uid));
            },
          );
        },
        data: (applications) {
          if (applications.isEmpty) {
            return const _EmptyApplicants();
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.refresh(startupApplicationsProvider(user.uid).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];

                return _ApplicantCard(
                  application: application,
                  formattedDate: formatDate(application.createdAt),
                  onStatusChanged: (status) {
                    updateStatus(
                      context: context,
                      ref: ref,
                      application: application,
                      status: status,
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

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final String formattedDate;
  final ValueChanged<String> onStatusChanged;

  const _ApplicantCard({
    required this.application,
    required this.formattedDate,
    required this.onStatusChanged,
  });

  Color statusColor() {
    switch (application.status.toLowerCase()) {
      case 'accepted':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'under review':
        return Colors.orange;

      case 'interview':
        return Colors.purple;

      default:
        return Colors.blue;
    }
  }

  IconData statusIcon() {
    switch (application.status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      case 'under review':
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

    final currentStatusColor = statusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                child: Text(
                  application.studentName.isNotEmpty
                      ? application.studentName[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.studentName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      application.studentEmail,
                      style: TextStyle(color: mutedTextColor, fontSize: 13),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      application.studyYear,
                      style: TextStyle(color: mutedTextColor, fontSize: 13),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                tooltip: 'Change status',
                onSelected: onStatusChanged,
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(value: 'Submitted', child: Text('Submitted')),
                    PopupMenuItem(
                      value: 'Under Review',
                      child: Text('Under Review'),
                    ),
                    PopupMenuItem(value: 'Interview', child: Text('Interview')),
                    PopupMenuItem(value: 'Accepted', child: Text('Accepted')),
                    PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            application.opportunityTitle,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 17,
                color: mutedTextColor,
              ),

              const SizedBox(width: 6),

              Text(
                'Applied: $formattedDate',
                style: TextStyle(color: mutedTextColor, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: currentStatusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon(), color: currentStatusColor, size: 18),

                const SizedBox(width: 6),

                Text(
                  application.status,
                  style: TextStyle(
                    color: currentStatusColor,
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
              'View applicant details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            children: [
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

              const SizedBox(height: 7),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  application.motivation,
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

class _EmptyApplicants extends StatelessWidget {
  const _EmptyApplicants();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 76,
              color: AppColors.mutedText,
            ),

            SizedBox(height: 16),

            Text(
              'No applicants yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),

            SizedBox(height: 8),

            Text(
              'Student applications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ApplicantsError({required this.message, required this.onRetry});

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
              'Unable to load applicants',
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
