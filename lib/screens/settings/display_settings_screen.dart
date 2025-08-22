import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class DisplaySettingsScreen extends StatelessWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appearanceSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.language,
                      style: Theme.of(context).textTheme.titleMedium),
                  RadioListTile<Locale?>(
                    title: Text(localizations.systemDefault),
                    value: null,
                    groupValue: appConfig.locale,
                    onChanged: (value) => appConfig.setLocale(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<Locale>(
                    title: Text(localizations.english),
                    value: const Locale('en'),
                    groupValue: appConfig.locale,
                    onChanged: (value) => appConfig.setLocale(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<Locale>(
                    title: Text(localizations.chinese),
                    value: const Locale('zh'),
                    groupValue: appConfig.locale,
                    onChanged: (value) => appConfig.setLocale(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.theme,
                      style: Theme.of(context).textTheme.titleMedium),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.systemDefault),
                    value: ThemeMode.system,
                    groupValue: appConfig.themeMode,
                    onChanged: (value) => appConfig.setThemeMode(value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.light),
                    value: ThemeMode.light,
                    groupValue: appConfig.themeMode,
                    onChanged: (value) => appConfig.setThemeMode(value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.dark),
                    value: ThemeMode.dark,
                    groupValue: appConfig.themeMode,
                    onChanged: (value) => appConfig.setThemeMode(value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const Divider(height: 32),
                  SwitchListTile(
                    title: Text(localizations.enableMonet),
                    subtitle: Text(localizations.monetTheming),
                    value: appConfig.enableMonet,
                    onChanged: (value) => appConfig.setEnableMonet(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.scrollSettings,
                      style: Theme.of(context).textTheme.titleMedium),
                  SwitchListTile(
                    title: Text(localizations.disableAutoScrollOnUp),
                    value: appConfig.disableAutoScrollOnUp,
                    onChanged: (value) =>
                        appConfig.setDisableAutoScrollOnUp(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  SwitchListTile(
                    title: Text(localizations.resumeAutoScrollOnBottom),
                    value: appConfig.resumeAutoScrollOnBottom,
                    onChanged: (value) =>
                        appConfig.setResumeAutoScrollOnBottom(value),
                    activeColor: Theme.of(context).colorScheme.primary,
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
