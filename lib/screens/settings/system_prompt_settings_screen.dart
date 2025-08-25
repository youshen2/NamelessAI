import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
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
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
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
            padding: const EdgeInsets.all(8),
            itemCount: manager.templates.length,
            itemBuilder: (context, index) {
              final template = manager.templates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      SelectableText(
                        template.prompt,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                    ],
                  ),
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
    showModalBottomSheet(
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
