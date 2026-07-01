import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock_opportunity.dart';
import '../../../providers/bookmark_provider.dart';
import '../widgets/opportunity_card.dart';
import 'opportunity_details_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() {
    return _ExploreScreenState();
  }
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String searchText = '';
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Software Development',
    'Marketing',
    'Design',
    'Business Research',
  ];

  @override
  Widget build(BuildContext context) {
    final bookmarkedIds = ref.watch(bookmarkProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    final filteredOpportunities = mockOpportunities.where((opportunity) {
      final searchQuery = searchText.toLowerCase();

      final matchesSearch =
          opportunity.title.toLowerCase().contains(searchQuery) ||
          opportunity.startupName.toLowerCase().contains(searchQuery) ||
          opportunity.location.toLowerCase().contains(searchQuery);

      final matchesCategory =
          selectedCategory == 'All' || opportunity.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Discover Opportunities',
              style: TextStyle(
                color: textColor,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Search for internships and startup projects.',
              style: TextStyle(color: mutedTextColor),
            ),

            const SizedBox(height: 20),

            // Search field
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by role, startup, or location',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),

            const SizedBox(height: 18),

            // Category filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${filteredOpportunities.length} opportunities found',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                if (searchText.isNotEmpty || selectedCategory != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchText = '';
                        selectedCategory = 'All';
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            if (filteredOpportunities.isEmpty)
              const _NoResultsMessage()
            else
              ...filteredOpportunities.map((opportunity) {
                return OpportunityCard(
                  opportunity: opportunity,
                  isBookmarked: bookmarkedIds.contains(opportunity.id),
                  onBookmarkTap: () {
                    ref
                        .read(bookmarkProvider.notifier)
                        .toggleBookmark(opportunity.id);
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

class _NoResultsMessage extends StatelessWidget {
  const _NoResultsMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 70, color: AppColors.mutedText),

          SizedBox(height: 14),

          Text(
            'No opportunities found',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),

          SizedBox(height: 7),

          Text(
            'Try using a different search word or category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
