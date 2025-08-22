import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class DisplaySettingsScreen extends StatelessWidget {
  const DisplaySettingsScreen({super.key});

  Widget _buildRadioGroup<T>({
    required BuildContext context,
    required String title,
    required T groupValue,
    required List<(String, T)> options,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...options.map((option) => RadioListTile<T>(
              title: Text(option.$1),
              value: option.$2,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            )),
      ],
    );
  }

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
            child: _buildRadioGroup<Locale?>(
              context: context,
              title: localizations.language,
              groupValue: appConfig.locale,
              options: [
                (localizations.systemDefault, null),
                (localizations.english, const Locale('en')),
                (localizations.chinese, const Locale('zh')),
              ],
              onChanged: (value) => appConfig.setLocale(value),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                _buildRadioGroup<ThemeMode>(
                  context: context,
                  title: localizations.theme,
                  groupValue: appConfig.themeMode,
                  options: [
                    (localizations.systemDefault, ThemeMode.system),
                    (localizations.light, ThemeMode.light),
                    (localizations.dark, ThemeMode.dark),
                  ],
                  onChanged: (value) => appConfig.setThemeMode(value!),
                ),
                const Divider(height: 16),
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
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(localizations.chatDisplay,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<FontSize>(
                      value: appConfig.fontSize,
                      decoration: InputDecoration(
                        labelText: localizations.fontSize,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: FontSize.small,
                            child: Text(localizations.small)),
                        DropdownMenuItem(
                            value: FontSize.medium,
                            child: Text(localizations.medium)),
                        DropdownMenuItem(
                            value: FontSize.large,
                            child: Text(localizations.large)),
                      ],
                      onChanged: (value) {
                        if (value != null) appConfig.setFontSize(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<ChatBubbleAlignment>(
                      value: appConfig.chatBubbleAlignment,
                      decoration: InputDecoration(
                        labelText: localizations.chatBubbleAlignment,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: ChatBubbleAlignment.normal,
                            child: Text(localizations.normal)),
                        DropdownMenuItem(
                            value: ChatBubbleAlignment.center,
                            child: Text(localizations.center)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          appConfig.setChatBubbleAlignment(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(localizations.showTimestamps),
                    value: appConfig.showTimestamps,
                    onChanged: appConfig.setShowTimestamps,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  SwitchListTile(
                    title: Text(localizations.showModelName),
                    subtitle: Text(localizations.showModelNameHint),
                    value: appConfig.showModelName,
                    onChanged: appConfig.setShowModelName,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  SwitchListTile(
                    title: Text(localizations.compactMode),
                    subtitle: Text(localizations.compactModeHint),
                    value: appConfig.compactMode,
                    onChanged: appConfig.setCompactMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                        '${localizations.chatBubbleWidth}: ${(appConfig.chatBubbleWidth * 100).round()}%'),
                  ),
                  Slider(
                    value: appConfig.chatBubbleWidth,
                    min: 0.5,
                    max: 1.0,
                    divisions: 5,
                    label: '${(appConfig.chatBubbleWidth * 100).round()}%',
                    onChanged: appConfig.setChatBubbleWidth,
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(localizations.scrollSettings,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
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
