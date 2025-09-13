import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.settings),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16,
            kToolbarHeight + MediaQuery.of(context).padding.top + 16,
            16,
            isDesktop ? 16 : 96),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(localizations.generalSettings),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/general');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(localizations.appearanceSettings),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/appearance');
                  },
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(localizations.notificationSettings),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/notifications');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.vibration),
                  title: Text(localizations.hapticSettings),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/haptics');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(localizations.appLock),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/app_lock');
                  },
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.api),
                  title: Text(localizations.apiProviderSettings),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/api_providers');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_books),
                  title: Text(localizations.systemPromptTemplates),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/system_prompts');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sd_storage_outlined),
                  title: Text(localizations.dataManagement),
                  onTap: () {
                    HapticService.onButtonPress(context);
                    context.go('/settings/data_management');
                  },
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(localizations.about),
              onTap: () {
                HapticService.onButtonPress(context);
                context.go('/settings/about');
              },
            ),
          ),
        ],
      ),
    );
  }
}
