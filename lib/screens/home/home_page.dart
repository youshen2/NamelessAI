import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/data/providers/chat_session_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/services/update_service.dart';
import 'package:nameless_ai/widgets/responsive_layout.dart';

class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdates();
      _handleSession();
    });
  }

  void _checkUpdates() {
    if (!mounted) return;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    if (appConfig.checkForUpdatesOnStartup) {
      UpdateService().check(context);
    }
  }

  void _handleSession() {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final chatSessionManager =
        Provider.of<ChatSessionManager>(context, listen: false);

    final currentLocation = GoRouterState.of(context).uri.toString();
    if (currentLocation == '/') {
      final defaultScreen = appConfig.defaultScreen;
      if (defaultScreen != '/') {
        context.go(defaultScreen);
      }
    }

    if (appConfig.restoreLastSession) {
      if (chatSessionManager.currentSession == null) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            chatSessionManager.loadLastSession();
          }
        });
      }
    } else {
      final apiProviderManager =
          Provider.of<APIProviderManager>(context, listen: false);
      if (chatSessionManager.currentSession == null ||
          !chatSessionManager.isNewSession) {
        chatSessionManager.startNewSession(
          providerId: apiProviderManager.selectedProvider?.id,
          modelId: apiProviderManager.selectedModel?.id,
        );
      }
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    if (isDesktop) {
      if (location.startsWith('/settings')) {
        return 1;
      }
      return 0;
    } else {
      if (location.startsWith('/history')) {
        return 1;
      }
      if (location.startsWith('/settings')) {
        return 2;
      }
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticService.onButtonPress(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    if (isDesktop) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/settings');
          break;
      }
    } else {
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
  }

  Widget _buildBottomNavBar(
      BuildContext context, AppLocalizations localizations, int selectedIndex) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    final navBar = BottomNavigationBar(
      backgroundColor: appConfig.enableBlurEffect
          ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
          : Theme.of(context).colorScheme.surface,
      elevation: 0,
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
    );

    if (appConfig.enableBlurEffect) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: navBar,
        ),
      );
    }
    return navBar;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final selectedIndex = _calculateSelectedIndex(context);

    return ResponsiveLayout(
      mobileBody: Scaffold(
        extendBody: true,
        body: widget.child,
        bottomNavigationBar:
            _buildBottomNavBar(context, localizations, selectedIndex),
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
                  icon: const Icon(Icons.settings),
                  label: Text(localizations.settings),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
