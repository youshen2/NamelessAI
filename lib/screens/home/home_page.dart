import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/widgets/responsive_layout.dart';

class HomePage extends StatelessWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/history')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final selectedIndex = _calculateSelectedIndex(context);

    return ResponsiveLayout(
      mobileBody: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              label: localizations.chat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: localizations.history,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: localizations.settings,
            ),
          ],
        ),
      ),
      desktopBody: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(localizations.chat),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.history),
                  label: Text(localizations.history),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings),
                  label: Text(localizations.settings),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
