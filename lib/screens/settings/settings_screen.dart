import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/display_settings_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDisplaySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        builder: (context, scrollController) =>
            DisplaySettingsSheet(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.api),
                  title: Text(localizations.apiProviderSettings),
                  onTap: () => context.go('/settings/api_providers'),
                ),
                ListTile(
                  leading: const Icon(Icons.library_books),
                  title: Text(localizations.systemPromptTemplates),
                  onTap: () => context.go('/settings/system_prompts'),
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(localizations.displaySettings),
                  onTap: () => _showDisplaySettings(context),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.sendKeySettings,
                      style: Theme.of(context).textTheme.titleMedium),
                  RadioListTile<SendKeyOption>(
                    title: Text(localizations.sendWithEnter),
                    value: SendKeyOption.enter,
                    groupValue: appConfig.sendKeyOption,
                    onChanged: (value) => appConfig.setSendKeyOption(value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<SendKeyOption>(
                    title: Text(localizations.sendWithCtrlEnter),
                    value: SendKeyOption.ctrlEnter,
                    groupValue: appConfig.sendKeyOption,
                    onChanged: (value) => appConfig.setSendKeyOption(value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<SendKeyOption>(
                    title: Text(localizations.sendWithShiftCtrlEnter),
                    value: SendKeyOption.shiftCtrlEnter,
                    groupValue: appConfig.sendKeyOption,
                    onChanged: (value) => appConfig.setSendKeyOption(value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: Text(localizations.shortcutInEditMode),
                    value: appConfig.useSendKeyInEditMode,
                    onChanged: (value) =>
                        appConfig.setUseSendKeyInEditMode(value),
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
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(localizations.about),
              onTap: () => context.go('/settings/about'),
            ),
          ),
        ],
      ),
    );
  }
}
