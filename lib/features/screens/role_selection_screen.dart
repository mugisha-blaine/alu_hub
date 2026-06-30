import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'home_screen.dart';

enum AccountRole { student, startup }

class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;

  const RoleSelectionScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  AccountRole? selectedRole;

  void completeRegistration() {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your account type.')),
      );

      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userName: widget.name,
          role: selectedRole == AccountRole.student ? 'Student' : 'Startup',
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              Text(
                'How will you use ALU_HUB?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your role helps us personalize your experience.',
                style: TextStyle(color: mutedTextColor, fontSize: 15),
              ),

              const SizedBox(height: 30),

              _RoleCard(
                title: 'Student',
                description:
                    'Discover internships, projects, and practical experience.',
                icon: Icons.school_outlined,
                selected: selectedRole == AccountRole.student,
                onTap: () {
                  setState(() {
                    selectedRole = AccountRole.student;
                  });
                },
              ),

              const SizedBox(height: 16),

              _RoleCard(
                title: 'Startup',
                description:
                    'Create a startup profile, post opportunities, and manage applicants.',
                icon: Icons.business_center_outlined,
                selected: selectedRole == AccountRole.startup,
                onTap: () {
                  setState(() {
                    selectedRole = AccountRole.startup;
                  });
                },
              ),

              const Spacer(),

              FilledButton(
                onPressed: completeRegistration,
                child: const Text('Complete Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.accentBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentBlue
                      : AppColors.primaryBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.primaryBlue,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: TextStyle(color: mutedTextColor, height: 1.35),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.accentBlue : AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
