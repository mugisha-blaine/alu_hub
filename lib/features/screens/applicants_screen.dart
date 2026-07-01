import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<ApplicantsScreen> createState() {
    return _ApplicantsScreenState();
  }
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final applicants = [
    {
      'name': 'Aline Uwase',
      'role': 'Flutter Development Intern',
      'status': 'Submitted',
    },
    {
      'name': 'Patrick Mugisha',
      'role': 'UI/UX Design Intern',
      'status': 'Under Review',
    },
    {
      'name': 'Grace Mutesi',
      'role': 'Digital Marketing Intern',
      'status': 'Shortlisted',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: applicants.length,
        itemBuilder: (context, index) {
          final applicant = applicants[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text(applicant['name']![0])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              applicant['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              applicant['role']!,
                              style: const TextStyle(
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: applicant['status'],
                    decoration: const InputDecoration(
                      labelText: 'Application status',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Submitted',
                        child: Text('Submitted'),
                      ),
                      DropdownMenuItem(
                        value: 'Under Review',
                        child: Text('Under Review'),
                      ),
                      DropdownMenuItem(
                        value: 'Shortlisted',
                        child: Text('Shortlisted'),
                      ),
                      DropdownMenuItem(
                        value: 'Accepted',
                        child: Text('Accepted'),
                      ),
                      DropdownMenuItem(
                        value: 'Rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          applicant['status'] = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
