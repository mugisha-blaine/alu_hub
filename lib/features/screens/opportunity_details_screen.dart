import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/opportunity.dart';
import 'application_form_screen.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDetailsScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opportunity saved')),
              );
            },
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.business_center_outlined,
                                color: AppColors.primaryBlue,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opportunity.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          opportunity.startupName,
                                          style: TextStyle(
                                            color: mutedTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      if (opportunity.isVerified) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.accentBlue,
                                          size: 19,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            _DetailChip(
                              icon: Icons.location_on_outlined,
                              label: opportunity.location,
                            ),
                            _DetailChip(
                              icon: Icons.schedule_outlined,
                              label: opportunity.workType,
                            ),
                            _DetailChip(
                              icon: Icons.category_outlined,
                              label: opportunity.category,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _InformationSection(
                    title: 'About this opportunity',
                    cardColor: cardColor,
                    textColor: textColor,
                    child: Text(
                      opportunity.description,
                      style: TextStyle(
                        color: mutedTextColor,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _InformationSection(
                    title: 'Skills required',
                    cardColor: cardColor,
                    textColor: textColor,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: opportunity.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _InformationSection(
                    title: 'Application deadline',
                    cardColor: cardColor,
                    textColor: textColor,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.accentBlue,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${opportunity.deadline.day}/'
                          '${opportunity.deadline.month}/'
                          '${opportunity.deadline.year}',
                          style: TextStyle(
                            color: mutedTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ApplicationFormScreen(opportunity: opportunity),
                    ),
                  );
                },
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Color cardColor;
  final Color textColor;

  const _InformationSection({
    required this.title,
    required this.child,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
