import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/screens/chat/chat_screen.dart';
import 'package:nameless_ai/screens/chat/screenshot_options_screen.dart';
import 'package:nameless_ai/screens/history/history_screen.dart';
import 'package:nameless_ai/screens/home/home_page.dart';
import 'package:nameless_ai/screens/onboarding/onboarding_screen.dart';
import 'package:nameless_ai/screens/settings/about_screen.dart';
import 'package:nameless_ai/screens/settings/api_provider_settings_screen.dart';
import 'package:nameless_ai/screens/settings/app_lock_settings_screen.dart';
import 'package:nameless_ai/screens/settings/app_settings_screen.dart';
import 'package:nameless_ai/screens/settings/appearance_settings_screen.dart';
import 'package:nameless_ai/screens/settings/data_management_screen.dart';
import 'package:nameless_ai/screens/settings/developer_options_screen.dart';
import 'package:nameless_ai/screens/settings/general_settings_screen.dart';
import 'package:nameless_ai/screens/settings/haptic_settings_screen.dart';
import 'package:nameless_ai/screens/settings/notification_settings_screen.dart';
import 'package:nameless_ai/screens/settings/settings_screen.dart';
import 'package:nameless_ai/screens/settings/system_prompt_settings_screen.dart';
import 'package:nameless_ai/screens/statistics/statistics_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Page<dynamic> _buildPageWithTransition<T>({
    required GoRouterState state,
    required Widget child,
    required PageTransitionType transitionType,
  }) {
    switch (transitionType) {
      case PageTransitionType.fade:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      case PageTransitionType.scale:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              ScaleTransition(scale: animation, child: child),
        );
      case PageTransitionType.slide:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case PageTransitionType.system:
      default:
        return MaterialPage<T>(key: state.pageKey, child: child);
    }
  }

  static GoRouter? _router;

  static GoRouter getRouter(BuildContext context) {
    if (_router != null) return _router!;

    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);

    _router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (appConfig.isFirstLaunch && state.uri.toString() != '/onboarding') {
          return '/onboarding';
        }
        return null;
      },
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return HomePage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'chat',
                  pageBuilder: (context, state) {
                    final appConfig = Provider.of<AppConfigProvider>(context);
                    return _buildPageWithTransition(
                      state: state,
                      child: const ChatScreen(),
                      transitionType: appConfig.pageTransitionType,
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  name: 'history',
                  pageBuilder: (context, state) {
                    final appConfig = Provider.of<AppConfigProvider>(context);
                    return _buildPageWithTransition(
                      state: state,
                      child: const HistoryScreen(),
                      transitionType: appConfig.pageTransitionType,
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/statistics',
                  name: 'statistics',
                  pageBuilder: (context, state) {
                    final appConfig = Provider.of<AppConfigProvider>(context);
                    return _buildPageWithTransition(
                      state: state,
                      child: const StatisticsScreen(),
                      transitionType: appConfig.pageTransitionType,
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  name: 'settings',
                  pageBuilder: (context, state) {
                    final appConfig = Provider.of<AppConfigProvider>(context);
                    return _buildPageWithTransition(
                      state: state,
                      child: const SettingsScreen(),
                      transitionType: appConfig.pageTransitionType,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'api_providers',
                      name: 'api_providers',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const APIProviderSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'system_prompts',
                      name: 'system_prompts',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const SystemPromptSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'about',
                      name: 'about',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const AboutScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'developer_options',
                      name: 'developer_options',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const DeveloperOptionsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'appearance',
                      name: 'appearance_settings',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const AppearanceSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'general',
                      name: 'general_settings',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const GeneralSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'app',
                      name: 'app_settings',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const AppSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'notifications',
                      name: 'notification_settings',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const NotificationSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'haptics',
                      name: 'haptic_settings',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const HapticSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'app_lock',
                      name: 'app_lock_settings',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const AppLockSettingsScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'data_management',
                      name: 'data_management',
                      pageBuilder: (context, state) {
                        final appConfig =
                            Provider.of<AppConfigProvider>(context);
                        return _buildPageWithTransition(
                          state: state,
                          child: const DataManagementScreen(),
                          transitionType: appConfig.pageTransitionType,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          pageBuilder: (context, state) {
            final appConfig = Provider.of<AppConfigProvider>(context);
            return _buildPageWithTransition(
              state: state,
              child: const OnboardingScreen(),
              transitionType: appConfig.pageTransitionType,
            );
          },
        ),
        GoRoute(
          path: '/screenshot',
          name: 'screenshot',
          pageBuilder: (context, state) {
            final messages = state.extra as List<ChatMessage>;
            final appConfig = Provider.of<AppConfigProvider>(context);
            return _buildPageWithTransition(
              state: state,
              child: ScreenshotOptionsScreen(messages: messages),
              transitionType: appConfig.pageTransitionType,
            );
          },
        ),
      ],
    );
    return _router!;
  }
}
