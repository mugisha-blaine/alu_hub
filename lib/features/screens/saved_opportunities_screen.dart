import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../widgets/opportunity_card.dart';

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkProvider);

    final opportunitiesAsync = ref.watch(activeOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Opportunities')),
      body: bookmarksAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _SavedError(
            message: 'Unable to load saved opportunities: $error',
            onRetry: () {
              ref.invalidate(bookmarkProvider);
            },
          );
        },
        data: (bookmarkedIds) {
          return opportunitiesAsync.when(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              return _SavedError(
                message: 'Unable to load opportunities: $error',
                onRetry: () {
                  ref.invalidate(activeOpportunitiesProvider);
                },
              );
            },
            data: (opportunities) {
              final savedOpportunities = opportunities.where((opportunity) {
                return bookmarkedIds.contains(opportunity.id);
              }).toList();

              if (savedOpportunities.isEmpty) {
                return const _EmptySavedScreen();
              }

              return RefreshIndicator(
                onRefresh: () {
                  ref.invalidate(bookmarkProvider);
                  ref.invalidate(activeOpportunitiesProvider);

                  return ref.read(activeOpportunitiesProvider.future);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: savedOpportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = savedOpportunities[index];

                    return OpportunityCard(
                      opportunity: opportunity,
                      isBookmarked: true,
                      onBookmarkTap: () {
                        ref
                            .read(bookmarkRepositoryProvider)
                            .toggleBookmark(
                              opportunityId: opportunity.id,
                              isCurrentlyBookmarked: true,
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text(
                              'Opportunity removed from saved items',
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const SavedOpportunitiesScreen();
                            },
                          ),
                        );
                      },
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

class _EmptySavedScreen extends StatelessWidget {
  const _EmptySavedScreen();

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
              Icons.bookmark_border_rounded,
              size: 78,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 17),
            Text(
              'No saved opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on an opportunity to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedTextColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SavedError({required this.message, required this.onRetry});

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
              'Something went wrong',
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
