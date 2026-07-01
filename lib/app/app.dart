import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/screens/onboarding_screen.dart';
import '../providers/theme_provider.dart';

class AluHubApp extends ConsumerWidget {
  const AluHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ALU_HUB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: selectedTheme,
      home: const OnboardingScreen(),
    );
  }
}
