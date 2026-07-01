import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock_opportunity.dart';

class ManageOpportunitiesScreen extends StatefulWidget {
  const ManageOpportunitiesScreen({super.key});

  @override
  State<ManageOpportunitiesScreen> createState() {
    return _ManageOpportunitiesScreenState();
  }
}

class _ManageOpportunitiesScreenState extends State<ManageOpportunitiesScreen> {
  late final List opportunities;

  @override
  void initState() {
    super.initState();
    opportunities = List.from(mockOpportunities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Opportunities')),
      body: opportunities.isEmpty
          ? const Center(child: Text('No opportunities available'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: opportunities.length,
              itemBuilder: (context, index) {
                final opportunity = opportunities[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 13),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primaryBlue,
                          child: Icon(
                            Icons.work_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opportunity.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                opportunity.workType,
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Edit form will use this opportunity when Firebase is added.',
                                  ),
                                ),
                              );
                            }

                            if (value == 'delete') {
                              setState(() {
                                opportunities.removeAt(index);
                              });
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ];
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
