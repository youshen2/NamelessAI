import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/services/update_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _isCheckingForUpdate = false;

  Future<void> _checkForUpdate() async {
    HapticService.onButtonPress(context);
    setState(() {
      _isCheckingForUpdate = true;
    });
    await UpdateService().check(context, showNoUpdateDialog: true);
    if (mounted) {
      setState(() {
        _isCheckingForUpdate = false;
      });
    }
  }

  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.appSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  title: Text(localizations.defaultStartupPage),
                  trailing: DropdownButton<String>(
                    value: appConfig.defaultScreen,
                    items: [
                      DropdownMenuItem(
                          value: '/', child: Text(localizations.chat)),
                      DropdownMenuItem(
                          value: '/history',
                          child: Text(localizations.history)),
                      DropdownMenuItem(
                          value: '/settings',
                          child: Text(localizations.settings)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        HapticService.onSwitchToggle(context);
                        appConfig.setDefaultScreen(value);
                      }
                    },
                  ),
                ),
                SwitchListTile(
                  title: Text(localizations.restoreLastSession),
                  subtitle: Text(localizations.restoreLastSessionHint),
                  value: appConfig.restoreLastSession,
                  onChanged: (value) {
                    HapticService.onSwitchToggle(context);
                    appConfig.setRestoreLastSession(value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(localizations.checkForUpdatesOnStartup),
                  value: appConfig.checkForUpdatesOnStartup,
                  onChanged: (value) {
                    HapticService.onSwitchToggle(context);
                    appConfig.setCheckForUpdatesOnStartup(value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                ListTile(
                  title: Text(localizations.checkForUpdates),
                  trailing: _isCheckingForUpdate
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.system_update_alt),
                  onTap: _isCheckingForUpdate ? null : _checkForUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
