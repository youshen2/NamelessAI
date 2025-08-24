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
  late TextEditingController _imaginePathController;
  late TextEditingController _fetchPathController;

  late bool _isStreamable;
  late ModelType _modelType;
  late ImageGenerationMode _imageGenerationMode;
  late CompatibilityMode _compatibilityMode;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController(text: widget.model?.name);
    _maxTokensController =
        TextEditingController(text: widget.model?.maxTokens?.toString() ?? '');
    _isStreamable = widget.model?.isStreamable ?? true;
    _modelType = widget.model?.modelType ?? ModelType.language;
    _imageGenerationMode =
        widget.model?.imageGenerationMode ?? ImageGenerationMode.instant;
    _compatibilityMode =
        widget.model?.compatibilityMode ?? CompatibilityMode.midjourneyProxy;
    _imaginePathController =
        TextEditingController(text: widget.model?.imaginePath);
    _fetchPathController = TextEditingController(text: widget.model?.fetchPath);
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _maxTokensController.dispose();
    _imaginePathController.dispose();
    _fetchPathController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final imaginePath = _imaginePathController.text.trim();
      final fetchPath = _fetchPathController.text.trim();
      final newModel = Model(
        id: widget.model?.id,
        name: _modelNameController.text,
        maxTokens: int.tryParse(_maxTokensController.text),
        isStreamable: _isStreamable,
        modelType: _modelType,
        imageGenerationMode: _imageGenerationMode,
        compatibilityMode: _compatibilityMode,
        imaginePath: imaginePath.isEmpty ? null : imaginePath,
        fetchPath: fetchPath.isEmpty ? null : fetchPath,
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
            if (_modelType == ModelType.image) ...[
              _buildImageModelSettings(localizations),
            ] else ...[
              _buildLanguageModelSettings(localizations),
            ],
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

  Widget _buildLanguageModelSettings(AppLocalizations localizations) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildImageModelSettings(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<ImageGenerationMode>(
          value: _imageGenerationMode,
          decoration:
              InputDecoration(labelText: localizations.imageGenerationMode),
          items: [
            DropdownMenuItem(
              value: ImageGenerationMode.instant,
              child: Text(localizations.instant),
            ),
            DropdownMenuItem(
              value: ImageGenerationMode.asynchronous,
              child: Text(localizations.asynchronous),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _imageGenerationMode = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        if (_imageGenerationMode == ImageGenerationMode.asynchronous) ...[
          DropdownButtonFormField<CompatibilityMode>(
            value: _compatibilityMode,
            decoration:
                InputDecoration(labelText: localizations.compatibilityMode),
            items: [
              DropdownMenuItem(
                value: CompatibilityMode.midjourneyProxy,
                child: Text(localizations.compatibilityModeMidjourney),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _compatibilityMode = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: Text(localizations.advancedSettings,
                style: Theme.of(context).textTheme.titleSmall),
            initiallyExpanded: false,
            childrenPadding: const EdgeInsets.only(top: 8),
            children: [
              TextFormField(
                controller: _imaginePathController,
                decoration: InputDecoration(
                  labelText: localizations.imaginePath,
                  hintText: localizations.asyncImaginePathHint,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fetchPathController,
                decoration: InputDecoration(
                  labelText: localizations.fetchPath,
                  hintText: localizations.asyncFetchPathHint('{taskId}'),
                ),
              ),
            ],
          ),
        ] else ...[
          ExpansionTile(
            title: Text(localizations.advancedSettings,
                style: Theme.of(context).textTheme.titleSmall),
            initiallyExpanded: false,
            childrenPadding: const EdgeInsets.only(top: 8),
            children: [
              TextFormField(
                controller: _imaginePathController,
                decoration: InputDecoration(
                  labelText: localizations.imaginePath,
                  hintText: '/v1/images/generations',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
