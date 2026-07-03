import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application.dart';

class ApplicationRepository {
  final FirebaseFirestore firestore;

  ApplicationRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get applicationsCollection {
    return firestore.collection('applications');
  }

  Future<bool> hasAlreadyApplied({
    required String studentId,
    required String opportunityId,
  }) {
    return applicationsCollection
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get()
        .then((snapshot) {
          return snapshot.docs.isNotEmpty;
        });
  }

  Future<void> submitApplication(ApplicationModel application) {
    return applicationsCollection.add(application.toFirestore());
  }

  Stream<List<ApplicationModel>> watchStudentApplications(String studentId) {
    return applicationsCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final applications = snapshot.docs
              .map(ApplicationModel.fromFirestore)
              .toList();

          applications.sort((first, second) {
            final firstDate = first.createdAt ?? DateTime(2000);

            final secondDate = second.createdAt ?? DateTime(2000);

            return secondDate.compareTo(firstDate);
          });

          return applications;
        });
  }

  Stream<List<ApplicationModel>> watchStartupApplications(String startupId) {
    return applicationsCollection
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(ApplicationModel.fromFirestore).toList();
        });
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) {
    return applicationsCollection.doc(applicationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
