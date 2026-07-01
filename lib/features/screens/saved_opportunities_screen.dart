import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../data/mock_opportunity.dart';
import '../../../providers/bookmark_provider.dart';
import '../widgets/opportunity_card.dart';
import '../screens/opportunity_details_screen.dart';

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarkProvider);

    final savedOpportunities = mockOpportunities.where((opportunity) {
      return bookmarkedIds.contains(opportunity.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Opportunities')),
      body: savedOpportunities.isEmpty
          ? const _EmptyBookmarks()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: savedOpportunities.length,
              itemBuilder: (context, index) {
                final opportunity = savedOpportunities[index];

                return OpportunityCard(
                  opportunity: opportunity,
                  isBookmarked: true,
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
              },
            ),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: AppColors.mutedText,
            ),
            SizedBox(height: 18),
            Text(
              'No saved opportunities',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on an opportunity to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
