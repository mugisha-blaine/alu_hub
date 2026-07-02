import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SkillsInterestsScreen extends StatefulWidget {
  const SkillsInterestsScreen({super.key});

  @override
  State<SkillsInterestsScreen> createState() {
    return _SkillsInterestsScreenState();
  }
}

class _SkillsInterestsScreenState extends State<SkillsInterestsScreen> {
  final portfolioController = TextEditingController();

  final List<String> availableSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX Design',
    'Marketing',
    'Research',
    'Data Analysis',
    'Communication',
    'Project Management',
    'Content Creation',
  ];

  final List<String> availableInterests = [
    'Software Development',
    'Design',
    'Marketing',
    'Business',
    'Research',
    'Operations',
  ];

  final Set<String> selectedSkills = {'Flutter', 'Communication'};

  final Set<String> selectedInterests = {'Software Development'};

  @override
  void dispose() {
    portfolioController.dispose();
    super.dispose();
  }

  void saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skills and interests saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skills and Interests')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Build Your Career Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 8),

            const Text(
              'Select your skills and interests so ALU_HUB can recommend suitable opportunities.',
              style: TextStyle(color: AppColors.mutedText, height: 1.4),
            ),

            const SizedBox(height: 25),

            const Text(
              'Your Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: availableSkills.map((skill) {
                final isSelected = selectedSkills.contains(skill);

                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedSkills.add(skill);
                      } else {
                        selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            const Text(
              'Career Interests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: availableInterests.map((interest) {
                final isSelected = selectedInterests.contains(interest);

                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedInterests.add(interest);
                      } else {
                        selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            const Text(
              'Portfolio Link',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: portfolioController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'GitHub, LinkedIn, or portfolio website',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed: saveProfile,
              child: const Text('Save Skills and Interests'),
            ),
          ],
        ),
      ),
    );
  }
}
