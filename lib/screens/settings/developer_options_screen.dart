import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/utils/helpers.dart';

class DeveloperOptionsScreen extends StatelessWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.developerOptions),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(localizations.exportSettings),
                  onTap: () {
                    showSnackBar(context, 'Not implemented yet');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download_done),
                  title: Text(localizations.importSettings),
                  onTap: () {
                    showSnackBar(context, 'Not implemented yet');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storage,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                  title: Text(
                    localizations.reinitializeDatabase,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(localizations.confirmDelete),
                        content:
                            Text(localizations.reinitializeDatabaseWarning),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localizations.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error),
                            child: Text(localizations.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await AppDatabase.reinitialize();
                      showSnackBar(
                          context, localizations.databaseReinitialized);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                  title: Text(
                    localizations.clearAllData,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(localizations.confirmDelete),
                        content: Text(localizations.clearDataConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localizations.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error),
                            child: Text(localizations.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await AppDatabase.clearAllData();
                      showSnackBar(context, localizations.dataCleared);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
