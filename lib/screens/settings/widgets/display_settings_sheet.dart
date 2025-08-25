import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class DisplaySettingsSheet extends StatelessWidget {
  final ScrollController scrollController;

  const DisplaySettingsSheet({
    super.key,
    required this.scrollController,
  });

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticService.onSwitchToggle(context);
          onChanged(newValue);
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        HapticService.onSwitchToggle(context);
        onChanged(!value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Column(
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
            localizations.displaySettings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                _buildSwitchTile(
                  context,
                  localizations.showTotalTime,
                  appConfig.showTotalTime,
                  appConfig.setShowTotalTime,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  context,
                  localizations.showFirstChunkTime,
                  appConfig.showFirstChunkTime,
                  appConfig.setShowFirstChunkTime,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  context,
                  localizations.showTokenUsage,
                  appConfig.showTokenUsage,
                  appConfig.setShowTokenUsage,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  context,
                  localizations.showOutputCharacters,
                  appConfig.showOutputCharacters,
                  appConfig.setShowOutputCharacters,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
