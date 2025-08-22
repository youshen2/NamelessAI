import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.generalSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(localizations.generalSettings,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  SwitchListTile(
                    title: Text(localizations.useFirstSentenceAsTitle),
                    subtitle: Text(localizations.useFirstSentenceAsTitleHint),
                    value: appConfig.useFirstSentenceAsTitle,
                    onChanged: appConfig.setUseFirstSentenceAsTitle,
                    activeColor: Theme.of(context).colorScheme.primary,
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
        ],
      ),
    );
  }
}
