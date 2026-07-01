import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock_opportunity.dart';
import '../widgets/opportunity_card.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String role;

  const HomeScreen({super.key, required this.userName, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> bookmarkedOpportunityIds = {};

  void toggleBookmark(String opportunityId) {
    setState(() {
      if (bookmarkedOpportunityIds.contains(opportunityId)) {
        bookmarkedOpportunityIds.remove(opportunityId);
      } else {
        bookmarkedOpportunityIds.add(opportunityId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final searchColor = isDarkMode ? AppColors.darkCard : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${widget.userName} 👋',
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
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),

            const SizedBox(height: 22),

            TextField(
              readOnly: true,
              onTap: () {
                // The Explore page will handle searching.
              },
              decoration: InputDecoration(
                hintText: 'Search internships and projects',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: const Icon(Icons.tune_rounded),
                filled: true,
                fillColor: searchColor,
              ),
            ),

            const SizedBox(height: 22),

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended for you',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View all')),
              ],
            ),

            const SizedBox(height: 8),

            ...mockOpportunities.take(3).map((opportunity) {
              return OpportunityCard(
                opportunity: opportunity,
                isBookmarked: bookmarkedOpportunityIds.contains(opportunity.id),
                onBookmarkTap: () {
                  toggleBookmark(opportunity.id);
                },
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${opportunity.title} details will be added next.',
                      ),
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
