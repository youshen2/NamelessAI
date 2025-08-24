import 'package:flutter/material.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class ExportOptionsSheet extends StatefulWidget {
  const ExportOptionsSheet({super.key});

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  final Map<String, bool> _options = {
    'apiProviders': true,
    'chatSessions': true,
    'systemPromptTemplates': true,
    'appConfig': true,
  };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.exportSettings,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(localizations.selectContentToExport),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text(localizations.apiProviderSettings),
              value: _options['apiProviders'],
              onChanged: (val) =>
                  setState(() => _options['apiProviders'] = val!),
            ),
            CheckboxListTile(
              title: Text(localizations.history),
              value: _options['chatSessions'],
              onChanged: (val) =>
                  setState(() => _options['chatSessions'] = val!),
            ),
            CheckboxListTile(
              title: Text(localizations.systemPromptTemplates),
              value: _options['systemPromptTemplates'],
              onChanged: (val) =>
                  setState(() => _options['systemPromptTemplates'] = val!),
            ),
            CheckboxListTile(
              title: Text(localizations.appSettings),
              value: _options['appConfig'],
              onChanged: (val) => setState(() => _options['appConfig'] = val!),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_options),
                  child: Text(localizations.exportData),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
