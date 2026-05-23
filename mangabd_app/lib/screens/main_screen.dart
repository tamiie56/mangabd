import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_provider.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'profile/profile_screen.dart';
import 'creator/creator_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookmarksScreen(),
    ProfileScreen(),
  ];

  final List<Widget> _creatorScreens = const [
    HomeScreen(),
    SearchScreen(),
    CreatorDashboardScreen(),
    BookmarksScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isCreator = auth.isCreator;
    final screens = isCreator ? _creatorScreens : _screens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentIndex >= screens.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentIndex = 0);
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132718) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex.clamp(0, screens.length - 1),
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          elevation: 0,
          height: 64,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'For You',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            if (isCreator)
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'My Works',
              ),
            const NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Bookmarks',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}