import 'package:flutter/material.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class ExportOptionsSheet extends StatefulWidget {
  const ExportOptionsSheet({super.key});

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  bool _exportSettings = true;
  bool _exportProviders = true;
  bool _exportChats = true;
  bool _exportPrompts = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Text(
            localizations.exportSettings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(localizations.selectContentToExport),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text(localizations.appSettings),
            value: _exportSettings,
            onChanged: (value) {
              HapticService.onSwitchToggle(context);
              setState(() => _exportSettings = value!);
            },
          ),
          CheckboxListTile(
            title: Text(localizations.apiProviderSettings),
            value: _exportProviders,
            onChanged: (value) {
              HapticService.onSwitchToggle(context);
              setState(() => _exportProviders = value!);
            },
          ),
          CheckboxListTile(
            title: Text(localizations.history),
            value: _exportChats,
            onChanged: (value) {
              HapticService.onSwitchToggle(context);
              setState(() => _exportChats = value!);
            },
          ),
          CheckboxListTile(
            title: Text(localizations.systemPromptTemplates),
            value: _exportPrompts,
            onChanged: (value) {
              HapticService.onSwitchToggle(context);
              setState(() => _exportPrompts = value!);
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              bottom: 24.0 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    HapticService.onButtonPress(context);
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    HapticService.onButtonPress(context);
                    Navigator.of(context).pop({
                      'settings': _exportSettings,
                      'providers': _exportProviders,
                      'chats': _exportChats,
                      'prompts': _exportPrompts,
                    });
                  },
                  child: Text(localizations.exportData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
