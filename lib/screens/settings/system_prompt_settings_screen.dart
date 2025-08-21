import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/data/providers/system_prompt_template_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
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
      ),
      body: Consumer<SystemPromptTemplateManager>(
        builder: (context, manager, child) {
          if (manager.templates.isEmpty) {
            return Center(
              child: Text(localizations.noSystemPromptTemplates),
            );
          }
          return ListView.builder(
            itemCount: manager.templates.length,
            itemBuilder: (context, index) {
              final template = manager.templates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(template.name),
                  subtitle: Text(template.prompt,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showTemplateForm(context, template: template),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                              context, localizations.systemPromptTemplates);
                          if (confirmed == true) {
                            await manager.deleteTemplate(template.id);
                            showSnackBar(context,
                                '${template.name} ${localizations.delete}d');
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => _showTemplateForm(context, template: template),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateForm(context),
        label: Text(localizations.addTemplate),
        icon: const Icon(Icons.add),
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

class SystemPromptTemplateForm extends StatefulWidget {
  final SystemPromptTemplate? template;
  final ScrollController? scrollController;

  const SystemPromptTemplateForm(
      {super.key, this.template, this.scrollController});

  @override
  State<SystemPromptTemplateForm> createState() =>
      _SystemPromptTemplateFormState();
}

class _SystemPromptTemplateFormState extends State<SystemPromptTemplateForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name);
    _promptController = TextEditingController(text: widget.template?.prompt);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    final localizations = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final manager =
          Provider.of<SystemPromptTemplateManager>(context, listen: false);
      final newTemplate = SystemPromptTemplate(
        id: widget.template?.id,
        name: _nameController.text,
        prompt: _promptController.text,
      );

      if (widget.template == null) {
        await manager.addTemplate(newTemplate);
        showSnackBar(
            context, '${newTemplate.name} ${localizations.addTemplate}d');
      } else {
        await manager.updateTemplate(newTemplate);
        showSnackBar(
            context, '${newTemplate.name} ${localizations.editTemplate}d');
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            widget.template == null
                ? localizations.addTemplate
                : localizations.editTemplate,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: localizations.templateName),
                      validator: (value) => value!.isEmpty
                          ? localizations.templateNameRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _promptController,
                      decoration: InputDecoration(
                          labelText: localizations.templatePrompt),
                      maxLines: 5,
                      minLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) => value!.isEmpty
                          ? localizations.templatePromptRequired
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveTemplate,
                  child: Text(localizations.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
