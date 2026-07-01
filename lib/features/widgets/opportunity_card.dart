import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.onBookmarkTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Card(
      color: cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.business_center_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                opportunity.startupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: mutedTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            if (opportunity.isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.accentBlue,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: isBookmarked
                        ? 'Remove bookmark'
                        : 'Save opportunity',
                    onPressed: onBookmarkTap,
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isBookmarked
                          ? AppColors.accentBlue
                          : mutedTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InformationChip(
                    icon: Icons.category_outlined,
                    text: opportunity.category,
                  ),
                  _InformationChip(
                    icon: Icons.location_on_outlined,
                    text: opportunity.location,
                  ),
                  _InformationChip(
                    icon: Icons.schedule_outlined,
                    text: opportunity.workType,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                opportunity.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: mutedTextColor, height: 1.4),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.accentBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Deadline: ${opportunity.deadline}',
                      style: TextStyle(
                        color: mutedTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformationChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryBlue),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
