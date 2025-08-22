import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/update_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _isCheckingForUpdate = false;

  Future<void> _checkForUpdate() async {
    setState(() {
      _isCheckingForUpdate = true;
    });
    await UpdateService().check(context, showNoUpdateDialog: true);
    if (mounted) {
      setState(() {
        _isCheckingForUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(localizations.checkForUpdatesOnStartup),
                  value: appConfig.checkForUpdatesOnStartup,
                  onChanged: appConfig.setCheckForUpdatesOnStartup,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                ListTile(
                  title: Text(localizations.checkForUpdates),
                  trailing: _isCheckingForUpdate
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.system_update_alt),
                  onTap: _isCheckingForUpdate ? null : _checkForUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
