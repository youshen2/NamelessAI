import 'package:flutter/material.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/services/import_service.dart';

class NamelessImportConfirmationDialog extends StatefulWidget {
  final Map<String, dynamic> backupData;

  const NamelessImportConfirmationDialog({super.key, required this.backupData});

  @override
  State<NamelessImportConfirmationDialog> createState() =>
      _NamelessImportConfirmationDialogState();
}

class _NamelessImportConfirmationDialogState
    extends State<NamelessImportConfirmationDialog> {
  ImportMode _importMode = ImportMode.merge;
  final Set<String> _selectedCategories = {};
  final Map<String, int> _categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _parseBackupData();
  }

  void _parseBackupData() {
    final data = widget.backupData;
    _updateCategory('apiProviders', data['apiProviders']);
    _updateCategory('chatSessions', data['chatSessions']);
    _updateCategory('systemPromptTemplates', data['systemPromptTemplates']);
    _updateCategory('appConfig', data['appConfig']);
  }

  void _updateCategory(String key, dynamic data) {
    if (data != null) {
      if (data is List && data.isNotEmpty) {
        _selectedCategories.add(key);
        _categoryCounts[key] = data.length;
      } else if (data is Map && data.isNotEmpty) {
        _selectedCategories.add(key);
        _categoryCounts[key] = 1;
      }
    }
  }

  String _getCategoryTitle(AppLocalizations localizations, String key) {
    final count = _categoryCounts[key];
    final countString = count != null && count > 1 ? ' ($count)' : '';
    switch (key) {
      case 'apiProviders':
        return '${localizations.apiProviderSettings}$countString';
      case 'chatSessions':
        return '${localizations.history}$countString';
      case 'systemPromptTemplates':
        return '${localizations.systemPromptTemplates}$countString';
      case 'appConfig':
        return localizations.appSettings;
      default:
        return key;
    }
  }

  IconData _getCategoryIcon(String key) {
    switch (key) {
      case 'apiProviders':
        return Icons.api;
      case 'chatSessions':
        return Icons.history;
      case 'systemPromptTemplates':
        return Icons.library_books;
      case 'appConfig':
        return Icons.apps;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(localizations.importPreview),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImportModeSelector(localizations, theme),
              const SizedBox(height: 24),
              Text(localizations.selectItemsToImport,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: _categoryCounts.keys.map((key) {
                    return CheckboxListTile(
                      secondary: Icon(_getCategoryIcon(key)),
                      title: Text(_getCategoryTitle(localizations, key)),
                      value: _selectedCategories.contains(key),
                      onChanged: (bool? value) {
                        HapticService.onSwitchToggle(context);
                        setState(() {
                          if (value == true) {
                            _selectedCategories.add(key);
                          } else {
                            _selectedCategories.remove(key);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticService.onButtonPress(context);
            Navigator.of(context).pop();
          },
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: _selectedCategories.isEmpty
              ? null
              : () {
                  HapticService.onButtonPress(context);
                  Navigator.of(context).pop({
                    'mode': _importMode,
                    'categories': _selectedCategories,
                  });
                },
          child: Text(localizations.import),
        ),
      ],
    );
  }

  Widget _buildImportModeSelector(
      AppLocalizations localizations, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.importMode, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ImportMode>(
          segments: [
            ButtonSegment(
              value: ImportMode.merge,
              label: Text(localizations.mergeData),
              icon: const Icon(Icons.add_circle_outline),
            ),
            ButtonSegment(
              value: ImportMode.replace,
              label: Text(localizations.replaceData),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
          selected: {_importMode},
          onSelectionChanged: (newSelection) {
            HapticService.onSwitchToggle(context);
            setState(() {
              _importMode = newSelection.first;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
          child: Text(
            _importMode == ImportMode.merge
                ? localizations.mergeDataHint
                : localizations.replaceDataHint,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
