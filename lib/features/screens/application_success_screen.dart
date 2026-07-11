import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ApplicationSuccessScreen extends StatelessWidget {
  final String opportunityTitle;
  final String startupName;

  const ApplicationSuccessScreen({
    super.key,
    required this.opportunityTitle,
    required this.startupName,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : AppColors.darkText;

    final mutedTextColor = isDarkMode ? Colors.white70 : AppColors.mutedText;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 115,
                width: 115,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 75,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Application Submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Your application for $opportunityTitle at $startupName has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedTextColor,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'You can follow its progress from the Applications page.',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedTextColor, fontSize: 14),
              ),

              const SizedBox(height: 35),

              FilledButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Return to Home'),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
