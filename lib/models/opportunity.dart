import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String startupId;
  final String title;
  final String startupName;
  final String category;
  final String location;
  final String workType;
  final DateTime deadline;
  final String description;
  final List<String> skills;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.title,
    required this.startupName,
    required this.category,
    required this.location,
    required this.workType,
    required this.deadline,
    required this.description,
    required this.skills,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
  });

  factory Opportunity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Opportunity(
      id: document.id,
      startupId: data['startupId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      startupName: data['startupName']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      workType: data['workType']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      isVerified: data['isVerified'] == true,
      isActive: data['isActive'] != false,
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startupId': startupId,
      'title': title,
      'startupName': startupName,
      'category': category,
      'location': location,
      'workType': workType,
      'deadline': Timestamp.fromDate(deadline),
      'description': description,
      'skills': skills,
      'isVerified': isVerified,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Opportunity copyWith({
    String? id,
    String? startupId,
    String? title,
    String? startupName,
    String? category,
    String? location,
    String? workType,
    DateTime? deadline,
    String? description,
    List<String>? skills,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Opportunity(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      title: title ?? this.title,
      startupName: startupName ?? this.startupName,
      category: category ?? this.category,
      location: location ?? this.location,
      workType: workType ?? this.workType,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
