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
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

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
        int targetIndex = 0;
        if (defaultScreen == '/history') targetIndex = 1;
        if (defaultScreen == '/settings') targetIndex = 2;
        widget.navigationShell.goBranch(targetIndex);
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

  void _onItemTapped(int index) {
    HapticService.onButtonPress(context);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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
      onTap: _onItemTapped,
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

    return ResponsiveLayout(
      mobileBody: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: _buildBottomNavBar(
            context, localizations, widget.navigationShell.currentIndex),
      ),
      desktopBody: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.navigationShell.currentIndex == 2 ? 1 : 0,
              onDestinationSelected: (index) {
                _onItemTapped(index == 0 ? 0 : 2);
              },
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
            Expanded(child: widget.navigationShell),
          ],
        ),
      ),
    );
  }
}
