import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/api_provider_presets.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/api_provider_form.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class APIProviderSettingsScreen extends StatefulWidget {
  const APIProviderSettingsScreen({super.key});

  @override
  State<APIProviderSettingsScreen> createState() =>
      _APIProviderSettingsScreenState();
}

class _APIProviderSettingsScreenState extends State<APIProviderSettingsScreen> {
  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final presets = getProviderPresets(localizations);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.apiProviderSettings),
        actions: [
          PopupMenuButton<dynamic>(
            icon: const Icon(Icons.add),
            tooltip: localizations.addProvider,
            onSelected: (value) {
              HapticService.onButtonPress(context);
              if (value == 'manual') {
                _showProviderForm(context, isEditing: false);
              } else if (value is APIProvider) {
                _showProviderForm(context, provider: value, isEditing: false);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'manual',
                child: Text(localizations.addProviderManually),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text(localizations.addFromPreset),
              ),
              ...presets.map((preset) => PopupMenuItem(
                    value: preset,
                    child: Text(preset.name),
                  )),
            ],
          ),
        ],
      ),
      body: Consumer<APIProviderManager>(
        builder: (context, manager, child) {
          if (manager.providers.isEmpty) {
            return Center(
              child: Text(localizations.noProvidersAdded),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 8, 16, isDesktop ? 16 : 96),
            itemCount: manager.providers.length,
            itemBuilder: (context, index) {
              final provider = manager.providers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(provider.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(provider.baseUrl,
                          overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: localizations.editProvider,
                            onPressed: () {
                              HapticService.onButtonPress(context);
                              _showProviderForm(context,
                                  provider: provider, isEditing: true);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: localizations.delete,
                            onPressed: () async {
                              HapticService.onButtonPress(context);
                              final confirmed = await showConfirmDialog(
                                  context, localizations.apiProviderSettings);
                              if (confirmed == true) {
                                await manager.deleteProvider(provider.id);
                                if (mounted) {
                                  showSnackBar(context,
                                      localizations.itemDeleted(provider.name));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (provider.models.isNotEmpty)
                            const Divider(height: 1),
                          if (provider.models.isNotEmpty)
                            const SizedBox(height: 12),
                          if (provider.models.isNotEmpty)
                            Text('${localizations.models}:',
                                style: Theme.of(context).textTheme.labelLarge),
                          if (provider.models.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(localizations.noModelsConfigured,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                            ),
                          ...provider.models.map((model) => Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0),
                                child: Text('• ${model.name}'),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProviderForm(BuildContext context,
      {APIProvider? provider, bool isEditing = false}) {
    showBlurredModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return APIProviderForm(
              provider: provider,
              isEditing: isEditing,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}
