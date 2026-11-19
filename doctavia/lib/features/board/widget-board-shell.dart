import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-content.dart';

/// The main app shell — wraps all role-based tab pages with a
/// role-aware bottom navigation bar. Registered in routing-tree.dart
/// as a [ShellRoute] builder for each role.
///
/// Lives in features/board/ because it IS the board: the persistent
/// frame that links all pages together via the navbar.
class AppBoard extends StatelessWidget {
  final String role;
  final Widget child;

  const AppBoard({super.key, required this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    final tabs = _tabsForRole(role);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(tabs, location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(tabs[index].route),
        destinations: tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }

  int _currentIndex(List<_Tab> tabs, String location) {
    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].route)) return i;
    }
    return 0;
  }

  List<_Tab> _tabsForRole(String role) {
    switch (role) {
      case 'doctor':
        return [
          _Tab(
            AppContent.get('board.nav.dashboard'),
            Icons.dashboard_outlined,
            Icons.dashboard,
            '/dashboard',
          ),
          _Tab(
            AppContent.get('board.nav.schedule'),
            Icons.event_note_outlined,
            Icons.event_note,
            '/schedule',
          ),
          _Tab(
            AppContent.get('board.nav.patients'),
            Icons.people_outline,
            Icons.people,
            '/patients',
          ),
          _Tab(
            AppContent.get('board.nav.profile'),
            Icons.person_outline,
            Icons.person,
            '/doctor/profile',
          ),
        ];
      case 'secretary':
        return [
          _Tab(
            AppContent.get('board.nav.dashboard'),
            Icons.dashboard_outlined,
            Icons.dashboard,
            '/secretary',
          ),
          _Tab(
            AppContent.get('board.nav.registry'),
            Icons.fact_check_outlined,
            Icons.fact_check,
            '/registry',
          ),
          _Tab(
            AppContent.get('board.nav.profile'),
            Icons.person_outline,
            Icons.person,
            '/secretary/profile',
          ),
        ];
      case 'patient':
      default:
        return [
          _Tab(
            AppContent.get('board.nav.home'),
            Icons.home_outlined,
            Icons.home,
            '/home',
          ),
          _Tab(
            AppContent.get('board.nav.search'),
            Icons.search,
            Icons.search,
            '/search',
          ),
          _Tab(
            AppContent.get('board.nav.reminders'),
            Icons.medication_outlined,
            Icons.medication,
            '/reminders',
          ),
          _Tab(
            AppContent.get('board.nav.bookings'),
            Icons.calendar_today_outlined,
            Icons.calendar_today,
            '/bookings',
          ),
          _Tab(
            AppContent.get('board.nav.profile'),
            Icons.person_outline,
            Icons.person,
            '/profile',
          ),
        ];
    }
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _Tab(this.label, this.icon, this.activeIcon, this.route);
}
