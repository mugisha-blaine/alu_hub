import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final bookmarkProvider = StreamProvider<Set<String>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () {
      return Stream.value(<String>{});
    },
    error: (error, stackTrace) {
      return Stream.value(<String>{});
    },
    data: (user) {
      if (user == null) {
        return Stream.value(<String>{});
      }

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((document) => document.id).toSet();
          });
    },
  );
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

class BookmarkRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void toggleBookmark({
    required String opportunityId,
    required bool isCurrentlyBookmarked,
  }) {
    final user = auth.currentUser;

    if (user == null) {
      return;
    }

    final bookmarkDocument = firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(opportunityId);

    if (isCurrentlyBookmarked) {
      bookmarkDocument.delete().catchError((error) {
        print('Unable to remove bookmark: $error');
      });
    } else {
      bookmarkDocument
          .set({
            'opportunityId': opportunityId,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .catchError((error) {
            print('Unable to save bookmark: $error');
          });
    }
  }
}
