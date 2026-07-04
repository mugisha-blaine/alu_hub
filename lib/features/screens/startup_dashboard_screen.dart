import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../providers/opportunity_provider.dart';
import 'create_opportunity_screen.dart';
import 'manage_opportunities_screen.dart';
import 'view_applicants.dart';

class StartupDashboardScreen extends ConsumerStatefulWidget {
  final String startupName;

  const StartupDashboardScreen({super.key, required this.startupName});

  @override
  ConsumerState<StartupDashboardScreen> createState() {
    return _StartupDashboardScreenState();
  }
}

class _StartupDashboardScreenState
    extends ConsumerState<StartupDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in again.')));
    }

    // Load this startup's opportunities.
    final opportunitiesAsync = ref.watch(
      startupOpportunitiesProvider(user.uid),
    );

    // Load applications sent to this startup.
    final applicationsAsync = ref.watch(startupApplicationsProvider(user.uid));

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            ref.invalidate(startupOpportunitiesProvider(user.uid));

            ref.invalidate(startupApplicationsProvider(user.uid));

            return ref.read(startupOpportunitiesProvider(user.uid).future);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome section
              Text(
                'Welcome, ${widget.startupName} 👋',
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Manage your opportunities and applicants.',
                style: TextStyle(color: mutedTextColor, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Dashboard statistics
              opportunitiesAsync.when(
                loading: () {
                  return const _StatisticsLoading();
                },
                error: (error, stackTrace) {
                  return _DashboardError(
                    message: 'Unable to load opportunities: $error',
                    onRetry: () {
                      ref.invalidate(startupOpportunitiesProvider(user.uid));
                    },
                  );
                },
                data: (opportunities) {
                  return applicationsAsync.when(
                    loading: () {
                      return const _StatisticsLoading();
                    },
                    error: (error, stackTrace) {
                      return _DashboardError(
                        message: 'Unable to load applications: $error',
                        onRetry: () {
                          ref.invalidate(startupApplicationsProvider(user.uid));
                        },
                      );
                    },
                    data: (applications) {
                      final totalOpportunities = opportunities.length;

                      final activeOpportunities = opportunities.where((
                        opportunity,
                      ) {
                        return opportunity.isActive;
                      }).length;

                      final totalApplicants = applications.length;

                      final acceptedApplicants = applications.where((
                        application,
                      ) {
                        return application.status.toLowerCase() == 'accepted';
                      }).length;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Opportunities',
                                  value: totalOpportunities.toString(),
                                  icon: Icons.work_outline_rounded,
                                  cardColor: cardColor,
                                  textColor: textColor,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _StatCard(
                                  title: 'Active Opportunities',
                                  value: activeOpportunities.toString(),
                                  icon: Icons.check_circle_outline_rounded,
                                  cardColor: cardColor,
                                  textColor: textColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Applicants',
                                  value: totalApplicants.toString(),
                                  icon: Icons.people_outline_rounded,
                                  cardColor: cardColor,
                                  textColor: textColor,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _StatCard(
                                  title: 'Accepted Applicants',
                                  value: acceptedApplicants.toString(),
                                  icon: Icons.person_add_alt_rounded,
                                  cardColor: cardColor,
                                  textColor: textColor,
                                ),
                              ),
                            ],
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
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 15),

              // Post opportunity action
              _ActionTile(
                icon: Icons.add_circle_outline_rounded,
                title: 'Post an Opportunity',
                description: 'Create a new internship or project opportunity.',
                cardColor: cardColor,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CreateOpportunityScreen(
                          startupName: widget.startupName,
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Manage opportunities action
              _ActionTile(
                icon: Icons.edit_note_rounded,
                title: 'Manage Opportunities',
                description:
                    'Edit, activate, deactivate, or delete your posts.',
                cardColor: cardColor,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ManageOpportunitiesScreen();
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // View applicants action
              _ActionTile(
                icon: Icons.groups_outlined,
                title: 'View Applicants',
                description:
                    'Review students who applied to your opportunities.',
                cardColor: cardColor,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ViewApplicantsScreen();
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color cardColor;
  final Color textColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color cardColor;
  final Color textColor;
  final Color mutedTextColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.cardColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 53,
                width: 53,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 27),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: TextStyle(
                        color: mutedTextColor,
                        fontSize: 13,
                        height: 1.35,
                      ),
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

class _StatisticsLoading extends StatelessWidget {
  const _StatisticsLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 45),

          const SizedBox(height: 12),

          Text(message, textAlign: TextAlign.center),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
