import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String phone;
  final String studyYear;
  final String portfolioUrl;
  final String motivation;
  final String status;
  final DateTime? createdAt;

  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.phone,
    required this.studyYear,
    required this.portfolioUrl,
    required this.motivation,
    required this.status,
    this.createdAt,
  });

  factory ApplicationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return ApplicationModel(
      id: document.id,
      opportunityId: data['opportunityId']?.toString() ?? '',
      opportunityTitle: data['opportunityTitle']?.toString() ?? '',
      startupId: data['startupId']?.toString() ?? '',
      startupName: data['startupName']?.toString() ?? '',
      studentId: data['studentId']?.toString() ?? '',
      studentName: data['studentName']?.toString() ?? '',
      studentEmail: data['studentEmail']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      studyYear: data['studyYear']?.toString() ?? '',
      portfolioUrl: data['portfolioUrl']?.toString() ?? '',
      motivation: data['motivation']?.toString() ?? '',
      status: data['status']?.toString() ?? 'Submitted',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'phone': phone,
      'studyYear': studyYear,
      'portfolioUrl': portfolioUrl,
      'motivation': motivation,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
