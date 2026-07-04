import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String applicationId;
  final String opportunityTitle;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.applicationId,
    required this.opportunityTitle,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return NotificationModel(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? 'applicationStatus',
      applicationId: data['applicationId']?.toString() ?? '',
      opportunityTitle: data['opportunityTitle']?.toString() ?? '',
      isRead: data['isRead'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
