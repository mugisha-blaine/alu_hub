import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'settings_screen.dart';

class StartupProfileScreen extends StatelessWidget {
  final String startupName;

  const StartupProfileScreen({super.key, required this.startupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.business_rounded, color: Colors.white, size: 55),
          ),
          const SizedBox(height: 15),
          Text(
            startupName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Recognized ALU Startup',
                style: TextStyle(color: AppColors.mutedText),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.verified_rounded,
                color: AppColors.accentBlue,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Startup Information'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ),
          const ListTile(
            leading: Icon(Icons.people_outline_rounded),
            title: Text('Team Members'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SettingsScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
