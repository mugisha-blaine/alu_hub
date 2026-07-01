import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StudentProfileScreen extends StatelessWidget {
  final String userName;

  const StudentProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(height: 190, color: AppColors.primaryBlue),

          Transform.translate(
            offset: const Offset(0, -65),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.accentBlue,
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      userName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'student@alustudent.com',
                      style: TextStyle(color: AppColors.mutedText),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ALU Student',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -45),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                  _ProfileMenuTile(
                    icon: Icons.school_outlined,
                    title: 'Skills and Portfolio',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                  _ProfileMenuTile(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Saved Opportunities',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                  _ProfileMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                  _ProfileMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help and Support',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color cardColor;
  final Color textColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () {},
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}
