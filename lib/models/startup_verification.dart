import 'package:cloud_firestore/cloud_firestore.dart';

class StartupVerificationModel {
  final String id;
  final String startupName;
  final String email;
  final String founderName;
  final String founderAluEmail;
  final String description;
  final String website;
  final String location;
  final bool isVerified;
  final String verificationStatus;
  final String verificationMessage;
  final DateTime? createdAt;

  const StartupVerificationModel({
    required this.id,
    required this.startupName,
    required this.email,
    required this.founderName,
    required this.founderAluEmail,
    required this.description,
    required this.website,
    required this.location,
    required this.isVerified,
    required this.verificationStatus,
    required this.verificationMessage,
    required this.createdAt,
  });

  factory StartupVerificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    final createdTimestamp = data['createdAt'];

    DateTime? createdDate;

    if (createdTimestamp is Timestamp) {
      createdDate = createdTimestamp.toDate();
    }

    return StartupVerificationModel(
      id: document.id,
      startupName:
          data['startupName']?.toString() ??
          data['name']?.toString() ??
          'Unnamed startup',
      email: data['email']?.toString() ?? '',
      founderName: data['founderName']?.toString() ?? '',
      founderAluEmail: data['founderAluEmail']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      website: data['website']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      isVerified: data['isVerified'] == true,
      verificationStatus: data['verificationStatus']?.toString() ?? 'Pending',
      verificationMessage: data['verificationMessage']?.toString() ?? '',
      createdAt: createdDate,
    );
  }
}
