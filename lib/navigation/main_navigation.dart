import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../features/screens/my_app_screen.dart';
import '../features/screens/explore_screen.dart';
import '../features/screens/home_screen.dart';
import '../features/screens/student_profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  final String role;

  const MainNavigation({super.key, required this.userName, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(userName: widget.userName, role: widget.role),
      const ExploreScreen(),
      const MyApplicationsScreen(),
      StudentProfileScreen(userName: widget.userName),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        indicatorColor: AppColors.primaryBlue.withOpacity(0.14),
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppColors.primaryBlue,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primaryBlue,
            ),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(
              Icons.description_rounded,
              color: AppColors.primaryBlue,
            ),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.primaryBlue,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
