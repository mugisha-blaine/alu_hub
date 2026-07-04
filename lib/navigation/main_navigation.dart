import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../features/screens/my_app_screen.dart';
import '../features/screens/explore_screen.dart';
import '../features/screens/home_screen.dart';
import '../features/screens/student_profile_screen.dart';
import '../features/screens/view_applicants.dart';
import '../features/screens/manage_opportunities_screen.dart';
import '../features/screens/startup_dashboard_screen.dart';
import '../features/screens/startup_profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  final String role;

  const MainNavigation({super.key, required this.userName, required this.role});

  @override
  State<MainNavigation> createState() {
    return _MainNavigationState();
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  bool get isStartup {
    return widget.role.toLowerCase() == 'startup';
  }

  @override
  Widget build(BuildContext context) {
    final studentPages = [
      HomeScreen(userName: widget.userName, role: widget.role),
      const ExploreScreen(),
      const MyApplicationsScreen(),
      StudentProfileScreen(),
    ];

    final startupPages = [
      StartupDashboardScreen(startupName: widget.userName),
      const ManageOpportunitiesScreen(),
      const ViewApplicantsScreen(),
      const StartupProfileScreen(),
    ];

    final pages = isStartup ? startupPages : studentPages;

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
        destinations: isStartup
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(
                    Icons.dashboard_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  selectedIcon: Icon(
                    Icons.work_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Posts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(
                    Icons.groups_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Applicants',
                ),
                NavigationDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(
                    Icons.business_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Profile',
                ),
              ]
            : const [
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
