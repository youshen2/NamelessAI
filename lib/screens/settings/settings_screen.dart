import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/backup_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isWorking = false;

  Future<void> _exportData() async {
    final localizations = AppLocalizations.of(context)!;
    final exportOptions = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      builder: (context) => const _ExportOptionsSheet(),
    );

    if (exportOptions == null) return;

    setState(() => _isWorking = true);
    try {
      await _backupService.exportData(context, options: exportOptions);
      if (mounted) {
        showSnackBar(context, localizations.exportSuccess);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, localizations.exportError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _importData() async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.importData),
        content: Text(localizations.importConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(localizations.importData),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isWorking = true);
    try {
      await _backupService.importData(context);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(localizations.importSuccess.split('.').first),
            content: Text(localizations.importSuccess),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, localizations.importError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: Stack(
        children: [
          ListView(
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
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: Text(localizations.generalSettings),
                      onTap: () => context.go('/settings/general'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(localizations.appearanceSettings),
                      onTap: () => context.go('/settings/display'),
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: Text(localizations.exportData),
                      onTap: _isWorking ? null : _exportData,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_done_outlined),
                      title: Text(localizations.importData),
                      onTap: _isWorking ? null : _importData,
                    ),
                  ],
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
          if (_isWorking)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExportOptionsSheet extends StatefulWidget {
  const _ExportOptionsSheet();

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  final Map<String, bool> _options = {
    'apiProviders': true,
    'chatSessions': true,
    'systemPromptTemplates': true,
    'appConfig': true,
  };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
            onChanged: (val) => setState(() => _options['apiProviders'] = val!),
          ),
          CheckboxListTile(
            title: Text(localizations.history),
            value: _options['chatSessions'],
            onChanged: (val) => setState(() => _options['chatSessions'] = val!),
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
    );
  }
}
