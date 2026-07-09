import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/application.dart';

class ApplicationRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ApplicationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get applicationsCollection {
    return firestore.collection('applications');
  }

  CollectionReference<Map<String, dynamic>> get notificationsCollection {
    return firestore.collection('notifications');
  }

  String getApplicationDocumentId({
    required String studentId,
    required String opportunityId,
  }) {
    return '${studentId}_$opportunityId';
  }

  Future<void> submitApplication(ApplicationModel application) {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return Future.error('You must sign in before applying.');
    }

    if (currentUser.uid != application.studentId) {
      return Future.error(
        'You cannot submit an application for another student.',
      );
    }

    final applicationId = getApplicationDocumentId(
      studentId: application.studentId,
      opportunityId: application.opportunityId,
    );

    final applicationDocument = applicationsCollection.doc(applicationId);

    return applicationDocument.set({
      ...application.toFirestore(),
      'studentId': application.studentId,
      'opportunityId': application.opportunityId,
      'startupId': application.startupId,
      'status': 'Submitted',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ApplicationModel>> watchStudentApplications(String studentId) {
    return applicationsCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final applications = snapshot.docs.map((document) {
            return ApplicationModel.fromFirestore(document);
          }).toList();

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
          final applications = snapshot.docs.map((document) {
            return ApplicationModel.fromFirestore(document);
          }).toList();

          applications.sort((first, second) {
            final firstDate = first.createdAt ?? DateTime(2000);

            final secondDate = second.createdAt ?? DateTime(2000);

            return secondDate.compareTo(firstDate);
          });

          return applications;
        });
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) {
    final startupUser = auth.currentUser;

    if (startupUser == null) {
      return Future.error('You must sign in before updating an application.');
    }

    final validStatuses = <String>[
      'Submitted',
      'Under Review',
      'Interview',
      'Accepted',
      'Rejected',
    ];

    if (!validStatuses.contains(status)) {
      return Future.error('Invalid application status.');
    }

    final applicationDocument = applicationsCollection.doc(applicationId);

    return applicationDocument.get().then((document) {
      if (!document.exists) {
        throw Exception('Application not found.');
      }

      final data = document.data() ?? <String, dynamic>{};

      final startupId = data['startupId']?.toString() ?? '';

      final studentId = data['studentId']?.toString() ?? '';

      final opportunityTitle =
          data['opportunityTitle']?.toString() ?? 'the opportunity';

      if (startupId != startupUser.uid) {
        throw Exception(
          'You do not have permission to update this application.',
        );
      }

      if (studentId.isEmpty) {
        throw Exception('The student information is missing.');
      }

      final notificationDocument = notificationsCollection.doc();

      final batch = firestore.batch();

      batch.update(applicationDocument, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(notificationDocument, {
        'userId': studentId,
        'title': 'Application Update',
        'message': 'Your application for $opportunityTitle is now $status.',
        'type': 'applicationStatus',
        'applicationId': applicationId,
        'opportunityTitle': opportunityTitle,
        'isRead': false,
        'createdBy': startupUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return batch.commit();
    });
  }
}
