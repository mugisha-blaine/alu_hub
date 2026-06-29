import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/screens/onboarding_screen.dart';

class AluHubApp extends StatelessWidget {
  const AluHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU_HUB',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      // The app follows the phone's light or dark mode.
      themeMode: ThemeMode.system,

      home: const OnboardingScreen(),
    );
  }
}
