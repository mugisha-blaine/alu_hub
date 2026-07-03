import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'applicants_screen.dart';
import 'create_opportunity_screen.dart';
import 'manage_opportunities_screen.dart';
import 'view_applicants.dart';

class StartupDashboardScreen extends StatelessWidget {
  final String startupName;

  const StartupDashboardScreen({super.key, required this.startupName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome, $startupName',
              style: TextStyle(
                color: textColor,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your startup opportunities and applicants.',
              style: TextStyle(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Grow your startup team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Post practical opportunities and connect with talented ALU students.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Row(
              children: [
                Expanded(
                  child: _StatisticCard(
                    number: '4',
                    label: 'Active posts',
                    icon: Icons.work_outline_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatisticCard(
                    number: '18',
                    label: 'Applicants',
                    icon: Icons.people_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              'Quick Actions',
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _ActionTile(
              icon: Icons.add_circle_outline_rounded,
              title: 'Post an opportunity',
              description: 'Create a new internship or project listing.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CreateOpportunityScreen(startupName: startupName);
                    },
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.edit_note_rounded,
              title: 'Manage opportunities',
              description: 'View, edit, or remove your opportunity posts.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ManageOpportunitiesScreen();
                    },
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.groups_outlined,
              title: 'Review applicants',
              description: 'View and update student application statuses.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ViewApplicantsScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const _StatisticCard({
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(13),
        onTap: onTap,
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
      ),
    );
  }
}
