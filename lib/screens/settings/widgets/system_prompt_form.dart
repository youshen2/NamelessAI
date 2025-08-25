import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/data/providers/system_prompt_template_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

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
    HapticService.onButtonPress(context);
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
      } else {
        await manager.updateTemplate(newTemplate);
      }
      if (mounted) {
        Navigator.pop(context);
      }
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
            widget.template == null
                ? localizations.addTemplate
                : localizations.editTemplate,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                controller: widget.scrollController,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        InputDecoration(labelText: localizations.templateName),
                    validator: (value) => value!.isEmpty
                        ? localizations.templateNameRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _promptController,
                    decoration: InputDecoration(
                        labelText: localizations.templatePrompt),
                    maxLines: 8,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    HapticService.onButtonPress(context);
                    Navigator.pop(context);
                  },
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
