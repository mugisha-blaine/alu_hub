import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleBookmark(String opportunityId) {
    final updatedBookmarks = Set<String>.from(state);

    if (updatedBookmarks.contains(opportunityId)) {
      updatedBookmarks.remove(opportunityId);
    } else {
      updatedBookmarks.add(opportunityId);
    }

    state = updatedBookmarks;
  }

  bool isBookmarked(String opportunityId) {
    return state.contains(opportunityId);
  }
}

final bookmarkProvider = NotifierProvider<BookmarkNotifier, Set<String>>(
  BookmarkNotifier.new,
);
