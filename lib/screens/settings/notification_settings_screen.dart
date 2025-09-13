import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissionsIfNeeded();
  }

  Future<void> _requestPermissionsIfNeeded() async {
    await NotificationService().requestPermissions();
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
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);
    final isSupported = NotificationService.isSupported();
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.notificationSettings),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16,
            kToolbarHeight + MediaQuery.of(context).padding.top + 16,
            16,
            isDesktop ? 16 : 96),
        children: [
          if (!isSupported)
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.notificationsNotSupported,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: SwitchListTile(
              title: Text(localizations.enableNotifications),
              value: appConfig.notificationsEnabled,
              onChanged: isSupported
                  ? (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setNotificationsEnabled(value);
                      if (value) {
                        _requestPermissionsIfNeeded();
                      }
                    }
                  : null,
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: AbsorbPointer(
              absorbing: !appConfig.notificationsEnabled || !isSupported,
              child: Opacity(
                opacity:
                    appConfig.notificationsEnabled && isSupported ? 1.0 : 0.5,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(localizations.showThinkingNotification),
                      subtitle:
                          Text(localizations.showThinkingNotificationHint),
                      value: appConfig.showThinkingNotification,
                      onChanged: (value) {
                        HapticService.onSwitchToggle(context);
                        appConfig.setShowThinkingNotification(value);
                      },
                    ),
                    SwitchListTile(
                      title: Text(localizations.showCompletionNotification),
                      subtitle:
                          Text(localizations.showCompletionNotificationHint),
                      value: appConfig.showCompletionNotification,
                      onChanged: (value) {
                        HapticService.onSwitchToggle(context);
                        appConfig.setShowCompletionNotification(value);
                      },
                    ),
                    SwitchListTile(
                      title: Text(localizations.showErrorNotification),
                      subtitle: Text(localizations.showErrorNotificationHint),
                      value: appConfig.showErrorNotification,
                      onChanged: (value) {
                        HapticService.onSwitchToggle(context);
                        appConfig.setShowErrorNotification(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
