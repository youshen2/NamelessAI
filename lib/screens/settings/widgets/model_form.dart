import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class ModelFormSheet extends StatefulWidget {
  final Model? model;
  const ModelFormSheet({super.key, this.model});

  @override
  State<ModelFormSheet> createState() => _ModelFormSheetState();
}

class _ModelFormSheetState extends State<ModelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _modelNameController;
  late TextEditingController _maxTokensController;
  late bool _isStreamable;
  late bool _supportsThinking;
  late ModelType _modelType;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController(text: widget.model?.name);
    _maxTokensController =
        TextEditingController(text: widget.model?.maxTokens?.toString() ?? '');
    _isStreamable = widget.model?.isStreamable ?? true;
    _supportsThinking = widget.model?.supportsThinking ?? false;
    _modelType = widget.model?.modelType ?? ModelType.language;
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newModel = Model(
        id: widget.model?.id,
        name: _modelNameController.text,
        maxTokens: int.tryParse(_maxTokensController.text),
        isStreamable: _isStreamable,
        supportsThinking: _supportsThinking,
        modelType: _modelType,
      );
      Navigator.pop(context, newModel);
    }
  }

  String _getLocalizedModelTypeName(BuildContext context, ModelType type) {
    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case ModelType.language:
        return localizations.modelTypeLanguage;
      case ModelType.image:
        return localizations.modelTypeImage;
      case ModelType.video:
        return localizations.modelTypeVideo;
      case ModelType.tts:
        return localizations.modelTypeTts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.model == null
                  ? localizations.addModel
                  : localizations.editModel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<ModelType>(
              value: _modelType,
              decoration: InputDecoration(labelText: localizations.modelLabel),
              items: ModelType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getLocalizedModelTypeName(context, type)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _modelType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelNameController,
              decoration: InputDecoration(labelText: localizations.modelName),
              validator: (value) =>
                  value!.isEmpty ? localizations.modelNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxTokensController,
              decoration: InputDecoration(labelText: localizations.maxTokens),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(localizations.isStreamable),
              value: _isStreamable,
              onChanged: (value) => setState(() => _isStreamable = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(localizations.supportsThinking),
              subtitle: Text(localizations.supportsThinkingHint),
              value: _supportsThinking,
              onChanged: (value) => setState(() => _supportsThinking = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _save,
                  child: Text(localizations.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
