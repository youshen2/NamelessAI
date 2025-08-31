import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class DeveloperOptionsScreen extends StatefulWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  State<DeveloperOptionsScreen> createState() => _DeveloperOptionsScreenState();
}

class _DeveloperOptionsScreenState extends State<DeveloperOptionsScreen> {
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.developerOptions),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, isDesktop ? 16 : 96),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(localizations.showDebugButton),
                    subtitle: Text(localizations.showDebugButtonHint),
                    value: appConfig.showDebugButton,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      appConfig.setShowDebugButton(value);
                    },
                  ),
                  ListTile(
                    title: Text(localizations.resetOnboarding),
                    subtitle: Text(localizations.resetOnboardingHint),
                    onTap: () async {
                      HapticService.onButtonPress(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(localizations.resetOnboarding),
                          content:
                              Text(localizations.resetOnboardingConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                Navigator.of(context).pop(false);
                              },
                              child: Text(localizations.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                Navigator.of(context).pop(true);
                              },
                              child: Text(localizations.reset),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await appConfig.resetOnboarding();
                        if (mounted) {
                          showSnackBar(context, localizations.onboardingReset);
                        }
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: Text(localizations.crashTest),
                    subtitle: Text(localizations.crashTestDescription),
                    onTap: () {
                      HapticService.onButtonPress(context);
                      throw Exception(
                          "This is a test crash from Developer Options!");
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.storage,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                    title: Text(
                      localizations.reinitializeDatabase,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    onTap: () async {
                      HapticService.onButtonPress(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(localizations.confirmDelete),
                          content:
                              Text(localizations.reinitializeDatabaseWarning),
                          actions: [
                            TextButton(
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                Navigator.of(context).pop(false);
                              },
                              child: Text(localizations.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                Navigator.of(context).pop(true);
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error),
                              child: Text(localizations.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await AppDatabase.reinitialize();
                        if (mounted) {
                          showSnackBar(
                              context, localizations.databaseReinitialized);
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_forever,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                    title: Text(
                      localizations.clearAllData,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    onTap: () async {
                      HapticService.onButtonPress(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(localizations.confirmDelete),
                          content: Text(localizations.clearDataConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                Navigator.of(context).pop(false);
                              },
                              child: Text(localizations.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                HapticService.onButtonPress(context);
                                Navigator.of(context).pop(true);
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error),
                              child: Text(localizations.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await AppDatabase.clearAllData();
                        if (mounted) {
                          showSnackBar(context, localizations.dataCleared);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
