import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../providers/opportunity_provider.dart';
import 'create_opportunity_screen.dart';
import 'manage_opportunities_screen.dart';
import 'view_applicants.dart';

class StartupDashboardScreen extends ConsumerWidget {
  final String startupName;

  const StartupDashboardScreen({super.key, required this.startupName});

  void openCreateOpportunity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateOpportunityScreen(startupName: startupName);
        },
      ),
    );
  }

  void openManageOpportunities(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const ManageOpportunitiesScreen();
        },
      ),
    );
  }

  void openApplicants(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const ViewApplicantsScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to open the dashboard.')),
      );
    }

    final opportunitiesAsync = ref.watch(
      startupOpportunitiesProvider(user.uid),
    );

    final applicationsAsync = ref.watch(startupApplicationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Startup Dashboard'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(startupOpportunitiesProvider(user.uid));

          ref.invalidate(startupApplicationsProvider(user.uid));

          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome, $startupName 👋',
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Manage your opportunities and applicants.',
              style: TextStyle(color: mutedTextColor, fontSize: 15),
            ),

            const SizedBox(height: 30),

            Text(
              'Overview',
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 14),

            opportunitiesAsync.when(
              loading: () {
                return const _OverviewLoading();
              },
              error: (error, stackTrace) {
                return _OverviewError(
                  message: 'Unable to load opportunities.',
                  onRetry: () {
                    ref.invalidate(startupOpportunitiesProvider(user.uid));
                  },
                );
              },
              data: (opportunities) {
                return applicationsAsync.when(
                  loading: () {
                    return const _OverviewLoading();
                  },
                  error: (error, stackTrace) {
                    return _OverviewError(
                      message: 'Unable to load applicants.',
                      onRetry: () {
                        ref.invalidate(startupApplicationsProvider(user.uid));
                      },
                    );
                  },
                  data: (applications) {
                    final activeCount = opportunities.where((opportunity) {
                      return opportunity.isActive;
                    }).length;

                    final acceptedCount = applications.where((application) {
                      return application.status == 'Accepted';
                    }).length;

                    final submittedCount = applications.where((application) {
                      return application.status == 'Submitted';
                    }).length;

                    return Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cards = [
                              _OverviewCard(
                                icon: Icons.work_outline_rounded,
                                number: opportunities.length.toString(),
                                label: 'Opportunities',
                              ),
                              _OverviewCard(
                                icon: Icons.check_circle_outline_rounded,
                                number: activeCount.toString(),
                                label: 'Active',
                              ),
                              _OverviewCard(
                                icon: Icons.groups_outlined,
                                number: applications.length.toString(),
                                label: 'Applicants',
                              ),
                              _OverviewCard(
                                icon: Icons.task_alt_rounded,
                                number: acceptedCount.toString(),
                                label: 'Accepted',
                              ),
                            ];

                            if (constraints.maxWidth >= 700) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: cards[0]),
                                  const SizedBox(width: 12),
                                  Expanded(child: cards[1]),
                                  const SizedBox(width: 12),
                                  Expanded(child: cards[2]),
                                  const SizedBox(width: 12),
                                  Expanded(child: cards[3]),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: cards[0]),
                                    const SizedBox(width: 12),
                                    Expanded(child: cards[1]),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: cards[2]),
                                    const SizedBox(width: 12),
                                    Expanded(child: cards[3]),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        _ApplicationSummaryCard(
                          submitted: submittedCount,
                          accepted: acceptedCount,
                          total: applications.length,
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            Text(
              'Quick Actions',
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 14),

            _QuickActionCard(
              icon: Icons.add_circle_outline_rounded,
              title: 'Post an Opportunity',
              description: 'Create a new internship or project opportunity.',
              onTap: () {
                openCreateOpportunity(context);
              },
            ),

            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.edit_note_rounded,
              title: 'Manage Opportunities',
              description: 'Edit, activate, deactivate, or delete your posts.',
              onTap: () {
                openManageOpportunities(context);
              },
            ),

            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.groups_outlined,
              title: 'View Applicants',
              description: 'Review students who applied to your opportunities.',
              onTap: () {
                openApplicants(context);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const _OverviewCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 23),
          ),

          const SizedBox(height: 14),

          Text(
            number,
            style: TextStyle(
              color: textColor,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: mutedTextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ApplicationSummaryCard extends StatelessWidget {
  final int submitted;
  final int accepted;
  final int total;

  const _ApplicationSummaryCard({
    required this.submitted,
    required this.accepted,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application summary',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  total == 0
                      ? 'No applications received yet.'
                      : '$submitted submitted • $accepted accepted',
                  style: TextStyle(color: mutedTextColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 27),
              ),

              const SizedBox(width: 15),

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

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(color: mutedTextColor, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: mutedTextColor,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _OverviewError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OverviewError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.primaryBlue,
            size: 28,
          ),

          const SizedBox(width: 12),

          Expanded(child: Text(message)),

          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
