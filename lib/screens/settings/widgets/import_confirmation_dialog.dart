import 'package:flutter/material.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/services/import_service.dart';
import 'package:nameless_ai/services/chatbox_models.dart';

class ImportConfirmationDialog extends StatefulWidget {
  final ChatBoxBackup backupData;

  const ImportConfirmationDialog({super.key, required this.backupData});

  @override
  State<ImportConfirmationDialog> createState() =>
      _ImportConfirmationDialogState();
}

class _ImportConfirmationDialogState extends State<ImportConfirmationDialog> {
  ImportMode _importMode = ImportMode.merge;
  final Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    if (widget.backupData.apiProviders.isNotEmpty) {
      _selectedCategories.add('apiProviders');
    }
    if (widget.backupData.chatSessions.isNotEmpty) {
      _selectedCategories.add('chatSessions');
    }
    if (widget.backupData.promptTemplates.isNotEmpty) {
      _selectedCategories.add('systemPromptTemplates');
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
                  children: [
                    if (widget.backupData.apiProviders.isNotEmpty)
                      _buildExpansionTile(
                        categoryKey: 'apiProviders',
                        title:
                            '${localizations.apiProviderSettings} (${widget.backupData.apiProviders.length})',
                        items: widget.backupData.apiProviders
                            .map((p) => p.name)
                            .toList(),
                        icon: Icons.api,
                      ),
                    if (widget.backupData.chatSessions.isNotEmpty)
                      _buildExpansionTile(
                        categoryKey: 'chatSessions',
                        title:
                            '${localizations.history} (${widget.backupData.chatSessions.length})',
                        items: widget.backupData.chatSessions
                            .map((s) => s.name)
                            .toList(),
                        icon: Icons.history,
                      ),
                    if (widget.backupData.promptTemplates.isNotEmpty)
                      _buildExpansionTile(
                        categoryKey: 'systemPromptTemplates',
                        title:
                            '${localizations.systemPromptTemplates} (${widget.backupData.promptTemplates.length})',
                        items: widget.backupData.promptTemplates
                            .map((t) => t.name)
                            .toList(),
                        icon: Icons.library_books,
                      ),
                  ],
                ),
              ),
              if (widget.backupData.unsupportedItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSkippedItems(localizations, theme),
              ],
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

  Widget _buildExpansionTile({
    required String categoryKey,
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Checkbox(
          value: _selectedCategories.contains(categoryKey),
          onChanged: (bool? value) {
            HapticService.onSwitchToggle(context);
            setState(() {
              if (value == true) {
                _selectedCategories.add(categoryKey);
              } else {
                _selectedCategories.remove(categoryKey);
              }
            });
          },
        ),
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            padding: const EdgeInsets.only(left: 24, right: 16),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index], overflow: TextOverflow.ellipsis),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkippedItems(AppLocalizations localizations, ThemeData theme) {
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: ExpansionTile(
        leading: Icon(Icons.warning_amber_rounded,
            color: theme.colorScheme.onTertiaryContainer),
        title: Text(
          '${localizations.skipped} (${widget.backupData.unsupportedItems.length})',
          style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
        ),
        children: [
          ListTile(
            dense: true,
            title: Text(localizations.unsupportedData,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
          ),
          ...widget.backupData.unsupportedItems.map(
            (item) => ListTile(
              title: Text(item,
                  style:
                      TextStyle(color: theme.colorScheme.onTertiaryContainer)),
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}
