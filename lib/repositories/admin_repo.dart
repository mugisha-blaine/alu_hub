import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/startup_verification.dart';

class AdminRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AdminRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection {
    return firestore.collection('users');
  }

  Stream<List<StartupVerificationModel>> watchStartupAccounts() {
    return usersCollection.where('role', isEqualTo: 'Startup').snapshots().map((
      snapshot,
    ) {
      final startups = snapshot.docs.map((document) {
        return StartupVerificationModel.fromFirestore(document);
      }).toList();

      startups.sort((first, second) {
        final firstDate = first.createdAt ?? DateTime(2000);

        final secondDate = second.createdAt ?? DateTime(2000);

        return secondDate.compareTo(firstDate);
      });

      return startups;
    });
  }

  Future<void> approveStartup(String startupId) {
    final admin = auth.currentUser;

    if (admin == null) {
      return Future.error('You must sign in as an administrator.');
    }

    return usersCollection.doc(startupId).update({
      'isVerified': true,
      'verificationStatus': 'Approved',
      'verificationMessage': '',
      'verifiedBy': admin.uid,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectStartup({
    required String startupId,
    required String reason,
  }) {
    final admin = auth.currentUser;

    if (admin == null) {
      return Future.error('You must sign in as an administrator.');
    }

    final cleanReason = reason.trim();

    if (cleanReason.isEmpty) {
      return Future.error('Please provide a rejection reason.');
    }

    return usersCollection.doc(startupId).update({
      'isVerified': false,
      'verificationStatus': 'Rejected',
      'verificationMessage': cleanReason,
      'verifiedBy': admin.uid,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveToPending(String startupId) {
    final admin = auth.currentUser;

    if (admin == null) {
      return Future.error('You must sign in as an administrator.');
    }

    return usersCollection.doc(startupId).update({
      'isVerified': false,
      'verificationStatus': 'Pending',
      'verificationMessage': '',
      'verifiedBy': admin.uid,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
