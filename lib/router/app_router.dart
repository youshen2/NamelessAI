import 'package:go_router/go_router.dart';
import 'package:nameless_ai/screens/chat/chat_screen.dart';
import 'package:nameless_ai/screens/history/history_screen.dart';
import 'package:nameless_ai/screens/home/home_page.dart';
import 'package:nameless_ai/screens/settings/about_screen.dart';
import 'package:nameless_ai/screens/settings/api_provider_settings_screen.dart';
import 'package:nameless_ai/screens/settings/developer_options_screen.dart';
import 'package:nameless_ai/screens/settings/settings_screen.dart';
import 'package:nameless_ai/screens/settings/system_prompt_settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'api_providers',
                name: 'api_providers',
                builder: (context, state) => const APIProviderSettingsScreen(),
              ),
              GoRoute(
                path: 'system_prompts',
                name: 'system_prompts',
                builder: (context, state) => const SystemPromptSettingsScreen(),
              ),
              GoRoute(
                path: 'about',
                name: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
              GoRoute(
                path: 'developer_options',
                name: 'developer_options',
                builder: (context, state) => const DeveloperOptionsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
