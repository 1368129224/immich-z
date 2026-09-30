import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';

/// The bottom-navigation shell hosting the five primary tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <(IconData, IconData, String)>[
    (Icons.photo_outlined, Icons.photo, 'Photos'),
    (Icons.search_outlined, Icons.search, 'Search'),
    (Icons.photo_album_outlined, Icons.photo_album, 'Albums'),
    (Icons.people_outline, Icons.people, 'People'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  void _onDestinationSelected(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _onDestinationSelected(context, i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.$1),
              selectedIcon: Icon(d.$2),
              label: d.$3,
            ),
        ],
      ),
      floatingActionButton: navigationShell.currentIndex == 2
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.backup),
              child: const Icon(Icons.backup),
            )
          : null,
    );
  }
}
