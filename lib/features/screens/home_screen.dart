import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/opportunity_provider.dart';
import 'notifications_screen.dart';
import 'opportunity_details_screen.dart';
import '../widgets/opportunity_card.dart';

class HomeScreen extends ConsumerWidget {
  final String userName;
  final String role;

  const HomeScreen({super.key, required this.userName, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(activeOpportunitiesProvider);

    final bookmarksAsync = ref.watch(bookmarkProvider);

    final bookmarkedIds = bookmarksAsync.value ?? <String>{};

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.refresh(activeOpportunitiesProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Greeting section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Find your next ALU opportunity',
                          style: TextStyle(color: mutedTextColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  IconButton.filledTonal(
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const NotificationsScreen();
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Promotional card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.rocket_launch_outlined,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Build experience with ALU startups',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Discover practical opportunities that match your skills and career interests.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recommended for you',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Open the Explore tab to view all opportunities.',
                          ),
                        ),
                      );
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Firestore opportunity results
              opportunitiesAsync.when(
                loading: () {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },

                error: (error, stackTrace) {
                  return _OpportunityError(
                    errorMessage: error.toString(),
                    onRetry: () {
                      ref.invalidate(activeOpportunitiesProvider);
                    },
                  );
                },

                data: (opportunities) {
                  if (opportunities.isEmpty) {
                    return const _EmptyOpportunities();
                  }

                  // Only show the first three on Home.
                  final recommendedOpportunities = opportunities
                      .take(3)
                      .toList();

                  return Column(
                    children: recommendedOpportunities.map((opportunity) {
                      final isBookmarked = bookmarkedIds.contains(
                        opportunity.id,
                      );

                      return OpportunityCard(
                        opportunity: opportunity,
                        isBookmarked: isBookmarked,
                        onBookmarkTap: () {
                          ref
                              .read(bookmarkRepositoryProvider)
                              .toggleBookmark(
                                opportunityId: opportunity.id,
                                isCurrentlyBookmarked: isBookmarked,
                              );

                          final message = isBookmarked
                              ? 'Opportunity removed from saved items'
                              : 'Opportunity saved';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(message),
                            ),
                          );
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return OpportunityDetailsScreen(
                                  opportunity: opportunity,
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOpportunities extends StatelessWidget {
  const _EmptyOpportunities();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.work_off_outlined, size: 70, color: AppColors.mutedText),
          SizedBox(height: 15),
          Text(
            'No opportunities available',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'New startup opportunities will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _OpportunityError extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _OpportunityError({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 65, color: Colors.red),
          const SizedBox(height: 15),
          const Text(
            'Unable to load opportunities',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
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
    );
  }
}
