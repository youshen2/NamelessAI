import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

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
                  title: Text(localizations.appearanceSettings),
                  onTap: () => context.go('/settings/display'),
                ),
              ],
            ),
          ),
          if (isDesktop)
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
