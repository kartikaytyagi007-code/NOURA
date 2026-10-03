import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/tokens.dart';
import 'routes.dart';

/// The five V1 destinations (blueprint §4). Order matches the shell branches in router.dart.
const shellDestinations = <({String label, IconData icon, IconData selectedIcon})>[
  (label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
  (label: 'Meals', icon: Icons.restaurant_menu_outlined, selectedIcon: Icons.restaurant_menu),
  (label: 'Coach', icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble),
  (label: 'Workout', icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center),
  (label: 'Progress', icon: Icons.insights_outlined, selectedIcon: Icons.insights),
];

/// Bottom-navigation shell. Each tab keeps its own navigation stack (StatefulShellRoute).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: [
          for (final d in shellDestinations)
            NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
        ],
      ),
    );
  }
}

/// Common page scaffold for a tab: title, settings entry point and a scrolling body.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.title, required this.children, this.scrollable = true});

  final String title;
  final List<Widget> children;

  /// False for a full-height flex layout (e.g. a chat screen with a pinned input bar) instead of the
  /// default scrolling list of sections. [children] is then laid out as a [Column] and may use
  /// [Expanded]/[Flexible] directly.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: scrollable
          ? ListView.separated(
              padding: const EdgeInsets.all(NSpace.pageMargin),
              itemCount: children.length,
              separatorBuilder: (_, _) => const SizedBox(height: NSpace.sm),
              itemBuilder: (_, i) => children[i],
            )
          : Column(children: children),
    );
  }
}
