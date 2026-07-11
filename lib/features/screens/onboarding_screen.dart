import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
    );
  }

  void openRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const RegisterScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 35),

                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: AppColors.primaryBlue,
                          size: 78,
                        ),
                      ),

                      const SizedBox(height: 35),

                      Text(
                        'Welcome to ALU Hub',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Discover startup opportunities, build experience, and connect with talented ALU students.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mutedTextColor,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _FeatureItem(
                        icon: Icons.search_rounded,
                        title: 'Discover Opportunities',
                        description:
                            'Explore internships and startup projects.',
                        textColor: textColor,
                        mutedTextColor: mutedTextColor,
                      ),

                      const SizedBox(height: 18),

                      _FeatureItem(
                        icon: Icons.assignment_outlined,
                        title: 'Track Applications',
                        description:
                            'Follow your application progress in real time.',
                        textColor: textColor,
                        mutedTextColor: mutedTextColor,
                      ),

                      const SizedBox(height: 18),

                      _FeatureItem(
                        icon: Icons.groups_outlined,
                        title: 'Connect with Startups',
                        description:
                            'Build practical experience with ALU ventures.',
                        textColor: textColor,
                        mutedTextColor: mutedTextColor,
                      ),

                      const Spacer(),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            openRegister(context);
                          },
                          child: const Text('Create Account'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            openLogin(context);
                          },
                          child: const Text('I Already Have an Account'),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color textColor;
  final Color mutedTextColor;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.textColor,
    required this.mutedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: TextStyle(color: mutedTextColor, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
