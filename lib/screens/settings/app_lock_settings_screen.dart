import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/authentication_service.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class AppLockSettingsScreen extends StatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  State<AppLockSettingsScreen> createState() => _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends State<AppLockSettingsScreen> {
  bool _isBiometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await AuthenticationService.canAuthenticate();
    if (mounted) {
      setState(() {
        _isBiometricsAvailable = available;
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
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.appLock),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16,
            kToolbarHeight + MediaQuery.of(context).padding.top + 16,
            16,
            isDesktop ? 16 : 96),
        children: [
          if (!_isBiometricsAvailable)
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
                        localizations.biometricsNotAvailable,
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
              title: Text(localizations.enableAppLock),
              subtitle: Text(localizations.enableAppLockHint),
              value: appConfig.appLockEnabled,
              onChanged: !_isBiometricsAvailable
                  ? null
                  : (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setAppLockEnabled(value);
                    },
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: AbsorbPointer(
              absorbing: !appConfig.appLockEnabled || !_isBiometricsAvailable,
              child: Opacity(
                opacity: appConfig.appLockEnabled && _isBiometricsAvailable
                    ? 1.0
                    : 0.5,
                child: ListTile(
                  title: Text(localizations.lockAfter),
                  subtitle: Text(localizations.lockAfterHint),
                  trailing: DropdownButton<AppLockTimeout>(
                    value: appConfig.appLockTimeout,
                    items: [
                      DropdownMenuItem(
                        value: AppLockTimeout.immediately,
                        child: Text(localizations.immediately),
                      ),
                      DropdownMenuItem(
                        value: AppLockTimeout.after1Minute,
                        child: Text(localizations.after1Minute),
                      ),
                      DropdownMenuItem(
                        value: AppLockTimeout.after5Minutes,
                        child: Text(localizations.after5Minutes),
                      ),
                      DropdownMenuItem(
                        value: AppLockTimeout.after15Minutes,
                        child: Text(localizations.after15Minutes),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        HapticService.onSwitchToggle(context);
                        appConfig.setAppLockTimeout(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
