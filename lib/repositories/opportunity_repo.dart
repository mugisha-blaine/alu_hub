import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/opportunity.dart';

class OpportunityRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  OpportunityRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get opportunitiesCollection {
    return firestore.collection('opportunities');
  }

  Stream<List<Opportunity>> watchActiveOpportunities() {
    return opportunitiesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final opportunities = snapshot.docs
              .map(Opportunity.fromFirestore)
              .toList();

          opportunities.sort((first, second) {
            final firstDate = first.createdAt ?? DateTime(2000);

            final secondDate = second.createdAt ?? DateTime(2000);

            return secondDate.compareTo(firstDate);
          });

          return opportunities;
        });
  }

  Stream<List<Opportunity>> watchStartupOpportunities(String startupId) {
    return opportunitiesCollection
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final opportunities = snapshot.docs
              .map(Opportunity.fromFirestore)
              .toList();

          opportunities.sort((first, second) {
            final firstDate = first.createdAt ?? DateTime(2000);

            final secondDate = second.createdAt ?? DateTime(2000);

            return secondDate.compareTo(firstDate);
          });

          return opportunities;
        });
  }

  Future<void> createOpportunity(Opportunity opportunity) {
    final user = auth.currentUser;

    if (user == null) {
      return Future.error('You must sign in before posting an opportunity.');
    }

    return firestore.collection('users').doc(user.uid).get().then((profile) {
      final data = profile.data() ?? <String, dynamic>{};

      final role = data['role']?.toString() ?? '';

      final isVerified = data['isVerified'] == true;

      if (role != 'Startup') {
        throw Exception('Only startup accounts can post opportunities.');
      }

      if (!isVerified) {
        throw Exception(
          'Your startup must be verified before posting opportunities.',
        );
      }

      final savedStartupName = data['startupName']?.toString().trim() ?? '';

      return opportunitiesCollection.add({
        ...opportunity.toFirestore(),
        'startupId': user.uid,
        'startupName': savedStartupName.isNotEmpty
            ? savedStartupName
            : opportunity.startupName,
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateOpportunity(Opportunity opportunity) {
    return opportunitiesCollection.doc(opportunity.id).update({
      ...opportunity.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOpportunity(String opportunityId) {
    return opportunitiesCollection.doc(opportunityId).delete();
  }

  Future<void> changeOpportunityStatus({
    required String opportunityId,
    required bool isActive,
  }) {
    return opportunitiesCollection.doc(opportunityId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
