import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/opportunity.dart';

class OpportunityRepository {
  final FirebaseFirestore firestore;

  OpportunityRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

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
          return snapshot.docs.map(Opportunity.fromFirestore).toList();
        });
  }

  Future<void> createOpportunity(Opportunity opportunity) {
    return opportunitiesCollection.add({
      ...opportunity.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOpportunity(Opportunity opportunity) {
    return opportunitiesCollection
        .doc(opportunity.id)
        .update(opportunity.toFirestore());
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
