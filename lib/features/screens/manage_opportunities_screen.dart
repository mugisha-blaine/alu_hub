import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/opportunity.dart';
import '../../providers/opportunity_provider.dart';
import 'edit_opportunity_screen.dart';

class ManageOpportunitiesScreen extends ConsumerWidget {
  const ManageOpportunitiesScreen({super.key});

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void changeStatus({
    required BuildContext context,
    required WidgetRef ref,
    required Opportunity opportunity,
  }) {
    ref
        .read(opportunityRepositoryProvider)
        .changeOpportunityStatus(
          opportunityId: opportunity.id,
          isActive: !opportunity.isActive,
        )
        .then((_) {
          if (!context.mounted) {
            return;
          }

          final message = opportunity.isActive
              ? 'Opportunity deactivated.'
              : 'Opportunity activated.';

          showMessage(context, message);
        })
        .catchError((error) {
          if (!context.mounted) {
            return;
          }

          showMessage(context, 'Unable to update opportunity: $error');
        });
  }

  void confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required Opportunity opportunity,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Opportunity'),
          content: Text(
            'Are you sure you want to delete "${opportunity.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ref
                    .read(opportunityRepositoryProvider)
                    .deleteOpportunity(opportunity.id)
                    .then((_) {
                      if (!context.mounted) {
                        return;
                      }

                      showMessage(context, 'Opportunity deleted successfully.');
                    })
                    .catchError((error) {
                      if (!context.mounted) {
                        return;
                      }

                      showMessage(
                        context,
                        'Unable to delete opportunity: $error',
                      );
                    });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must sign in to manage opportunities.')),
      );
    }

    final opportunitiesAsync = ref.watch(
      startupOpportunitiesProvider(user.uid),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Opportunities')),
      body: opportunitiesAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _OpportunityError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(startupOpportunitiesProvider(user.uid));
            },
          );
        },
        data: (opportunities) {
          if (opportunities.isEmpty) {
            return const _EmptyOpportunities();
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.refresh(startupOpportunitiesProvider(user.uid).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: opportunities.length,
              itemBuilder: (context, index) {
                final opportunity = opportunities[index];

                return _ManageOpportunityCard(
                  opportunity: opportunity,
                  formattedDeadline: formatDate(opportunity.deadline),
                  onStatusChanged: () {
                    changeStatus(
                      context: context,
                      ref: ref,
                      opportunity: opportunity,
                    );
                  },
                  onDelete: () {
                    confirmDelete(
                      context: context,
                      ref: ref,
                      opportunity: opportunity,
                    );
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EditOpportunityScreen(
                            opportunity: opportunity,
                          );
                        },
                      ),
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

class _ManageOpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final String formattedDeadline;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ManageOpportunityCard({
    required this.opportunity,
    required this.formattedDeadline,
    required this.onStatusChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final statusColor = opportunity.isActive ? Colors.green : Colors.orange;

    final statusText = opportunity.isActive ? 'Active' : 'Inactive';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${opportunity.category} • ${opportunity.workType}',
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'status') {
                    onStatusChanged();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'status',
                      child: Text(
                        opportunity.isActive ? 'Deactivate' : 'Activate',
                      ),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.calendar_month_outlined,
                size: 17,
                color: AppColors.mutedText,
              ),

              const SizedBox(width: 5),

              Text(
                formattedDeadline,
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

class _EmptyOpportunities extends StatelessWidget {
  const _EmptyOpportunities();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 75, color: AppColors.mutedText),
            SizedBox(height: 15),
            Text(
              'No opportunity posts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(
              'Create an opportunity from your startup dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OpportunityError({required this.message, required this.onRetry});

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
              'Unable to load your opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
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
