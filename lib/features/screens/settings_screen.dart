import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          RadioListTile<ThemeMode>(
            title: const Text('Use device theme'),
            secondary: const Icon(Icons.phone_android_rounded),
            value: ThemeMode.system,
            groupValue: selectedTheme,
            onChanged: (_) {
              ref.read(themeModeProvider.notifier).useSystemTheme();
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light theme'),
            secondary: const Icon(Icons.light_mode_outlined),
            value: ThemeMode.light,
            groupValue: selectedTheme,
            onChanged: (_) {
              ref.read(themeModeProvider.notifier).useLightTheme();
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark theme'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: ThemeMode.dark,
            groupValue: selectedTheme,
            onChanged: (_) {
              ref.read(themeModeProvider.notifier).useDarkTheme();
            },
          ),
          const Divider(height: 35),
          const Text(
            'Account',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryBlue,
            ),
            title: const Text('Notification preferences'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryBlue,
            ),
            title: const Text('Privacy and security'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () {},
          ),
          const Divider(height: 35),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              'Sign out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Sign out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
