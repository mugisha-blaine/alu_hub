import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock_opportunity.dart';
import '../../providers/bookmark_provider.dart';
import 'notifications_screen.dart';
import 'opportunity_details_screen.dart';
import '../widgets/opportunity_card.dart';

class HomeScreen extends ConsumerWidget {
  final String userName;
  final String role;

  const HomeScreen({super.key, required this.userName, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarkProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final searchColor = isDarkMode ? AppColors.darkCard : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Greeting and notification button
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

            const SizedBox(height: 20),

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

            // Recommended section heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

            // Display the first three opportunities
            ...mockOpportunities.take(3).map((opportunity) {
              final isBookmarked = bookmarkedIds.contains(opportunity.id);

              return OpportunityCard(
                opportunity: opportunity,
                isBookmarked: isBookmarked,
                onBookmarkTap: () {
                  ref
                      .read(bookmarkProvider.notifier)
                      .toggleBookmark(opportunity.id);

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
            }),
          ],
        ),
      ),
    );
  }
}
