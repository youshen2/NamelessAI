import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/data/providers/system_prompt_template_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/system_prompt_form.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class SystemPromptSettingsScreen extends StatefulWidget {
  const SystemPromptSettingsScreen({super.key});

  @override
  State<SystemPromptSettingsScreen> createState() =>
      _SystemPromptSettingsScreenState();
}

class _SystemPromptSettingsScreenState
    extends State<SystemPromptSettingsScreen> {
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

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.systemPromptTemplates),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: localizations.addTemplate,
            onPressed: () {
              HapticService.onButtonPress(context);
              _showTemplateForm(context);
            },
          ),
        ],
      ),
      body: Consumer<SystemPromptTemplateManager>(
        builder: (context, manager, child) {
          if (manager.templates.isEmpty) {
            return Center(
              child: Text(localizations.noSystemPromptTemplates),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 8, 16, isDesktop ? 16 : 96),
            itemCount: manager.templates.length,
            itemBuilder: (context, index) {
              final template = manager.templates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(template.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: localizations.editTemplate,
                            onPressed: () {
                              HapticService.onButtonPress(context);
                              _showTemplateForm(context, template: template);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: localizations.delete,
                            onPressed: () async {
                              HapticService.onButtonPress(context);
                              final confirmed = await showConfirmDialog(
                                  context, localizations.systemPromptTemplates);
                              if (confirmed == true) {
                                await manager.deleteTemplate(template.id);
                                if (mounted) {
                                  showSnackBar(context,
                                      localizations.itemDeleted(template.name));
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
                      child: SelectableText(
                        template.prompt,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTemplateForm(BuildContext context,
      {SystemPromptTemplate? template}) {
    showBlurredModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SystemPromptTemplateForm(
              template: template,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}
