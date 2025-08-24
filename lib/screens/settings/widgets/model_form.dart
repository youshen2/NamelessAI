import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/api_path_template_selection_sheet.dart';

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
  late TextEditingController _chatPathController;
  late TextEditingController _createVideoPathController;
  late TextEditingController _queryVideoPathController;

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
    _chatPathController = TextEditingController(text: widget.model?.chatPath);
    _createVideoPathController =
        TextEditingController(text: widget.model?.createVideoPath);
    _queryVideoPathController =
        TextEditingController(text: widget.model?.queryVideoPath);

    if (widget.model == null) {
      _autoPopulatePaths();
    }
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _maxTokensController.dispose();
    _imaginePathController.dispose();
    _fetchPathController.dispose();
    _chatPathController.dispose();
    _createVideoPathController.dispose();
    _queryVideoPathController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final imaginePath = _imaginePathController.text.trim();
      final fetchPath = _fetchPathController.text.trim();
      final chatPath = _chatPathController.text.trim();
      final createVideoPath = _createVideoPathController.text.trim();
      final queryVideoPath = _queryVideoPathController.text.trim();

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
        chatPath: chatPath.isEmpty ? null : chatPath,
        createVideoPath: createVideoPath.isEmpty ? null : createVideoPath,
        queryVideoPath: queryVideoPath.isEmpty ? null : queryVideoPath,
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

  List<ApiPathTemplate> _getTemplates(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      ApiPathTemplate(
        name: localizations.apiPathTemplateQingyunTop,
        modelType: ModelType.language,
        chatPath: '/v1/chat/completions',
      ),
      ApiPathTemplate(
        name: localizations.apiPathTemplateQingyunTop,
        modelType: ModelType.image,
        imageGenerationMode: ImageGenerationMode.instant,
        imaginePath: '/v1/images/generations',
      ),
      ApiPathTemplate(
        name: localizations.apiPathTemplateQingyunTop,
        modelType: ModelType.image,
        imageGenerationMode: ImageGenerationMode.asynchronous,
        imaginePath: '/mj/submit/imagine',
        fetchPath: '/mj/task/{taskId}/fetch',
      ),
      ApiPathTemplate(
        name: localizations.apiPathTemplateStandardOpenAI,
        modelType: ModelType.language,
        chatPath: '/v1/chat/completions',
      ),
      ApiPathTemplate(
        name: localizations.apiPathTemplateStandardOpenAI,
        modelType: ModelType.image,
        imageGenerationMode: ImageGenerationMode.instant,
        imaginePath: '/v1/images/generations',
      ),
      ApiPathTemplate(
        name: localizations.apiPathTemplateQingyunTopVeo,
        modelType: ModelType.video,
        createVideoPath: '/v1/video/create',
        queryVideoPath: '/v1/video/query',
      ),
    ];
  }

  void _autoPopulatePaths() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final templates = _getTemplates(context);

      final relevantTemplates = templates.where((t) {
        final typeMatch = t.modelType == _modelType;
        final imageModeMatch = _modelType != ModelType.image ||
            t.imageGenerationMode == _imageGenerationMode;
        return typeMatch && imageModeMatch;
      }).toList();

      if (relevantTemplates.isNotEmpty) {
        final firstTemplate = relevantTemplates.first;
        setState(() {
          _chatPathController.text = firstTemplate.chatPath ?? '';
          _imaginePathController.text = firstTemplate.imaginePath ?? '';
          _fetchPathController.text = firstTemplate.fetchPath ?? '';
          _createVideoPathController.text = firstTemplate.createVideoPath ?? '';
          _queryVideoPathController.text = firstTemplate.queryVideoPath ?? '';
        });
      } else {
        setState(() {
          _chatPathController.clear();
          _imaginePathController.clear();
          _fetchPathController.clear();
          _createVideoPathController.clear();
          _queryVideoPathController.clear();
        });
      }
    });
  }

  void _showTemplateSelection() async {
    final result = await showModalBottomSheet<ApiPathTemplate>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ApiPathTemplateSelectionSheet(
        modelType: _modelType,
        imageGenerationMode: _imageGenerationMode,
      ),
    );

    if (result != null) {
      setState(() {
        if (result.chatPath != null) {
          _chatPathController.text = result.chatPath!;
        }
        if (result.imaginePath != null) {
          _imaginePathController.text = result.imaginePath!;
        }
        if (result.fetchPath != null) {
          _fetchPathController.text = result.fetchPath!;
        }
        if (result.createVideoPath != null) {
          _createVideoPathController.text = result.createVideoPath!;
        }
        if (result.queryVideoPath != null) {
          _queryVideoPathController.text = result.queryVideoPath!;
        }
      });
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
                    _autoPopulatePaths();
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
            if (_modelType != ModelType.language)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizations.nonLanguageModelPathWarning,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_modelType == ModelType.image) ...[
              _buildImageModelSettings(localizations),
            ] else if (_modelType == ModelType.video) ...[
              _buildVideoModelSettings(localizations),
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
        const SizedBox(height: 8),
        ExpansionTile(
          title: Text(localizations.advancedSettings,
              style: Theme.of(context).textTheme.titleSmall),
          initiallyExpanded: false,
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.apiPathTemplate,
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _showTemplateSelection,
                  icon: const Icon(Icons.library_books_outlined, size: 18),
                  label: Text(localizations.selectApiPathTemplate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _chatPathController,
              decoration: InputDecoration(
                labelText: localizations.chatPath,
                hintText: localizations.chatPathHint,
              ),
            ),
          ],
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
                _autoPopulatePaths();
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
        ],
        ExpansionTile(
          title: Text(localizations.advancedSettings,
              style: Theme.of(context).textTheme.titleSmall),
          initiallyExpanded: false,
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.apiPathTemplate,
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _showTemplateSelection,
                  icon: const Icon(Icons.library_books_outlined, size: 18),
                  label: Text(localizations.selectApiPathTemplate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_imageGenerationMode == ImageGenerationMode.asynchronous) ...[
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
            ] else ...[
              TextFormField(
                controller: _imaginePathController,
                decoration: InputDecoration(
                  labelText: localizations.imaginePath,
                  hintText: localizations.imageGenerationPathHint,
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildVideoModelSettings(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          title: Text(localizations.advancedSettings,
              style: Theme.of(context).textTheme.titleSmall),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.apiPathTemplate,
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _showTemplateSelection,
                  icon: const Icon(Icons.library_books_outlined, size: 18),
                  label: Text(localizations.selectApiPathTemplate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _createVideoPathController,
              decoration: InputDecoration(
                labelText: localizations.createVideoPath,
                hintText: localizations.createVideoPathHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _queryVideoPathController,
              decoration: InputDecoration(
                labelText: localizations.queryVideoPath,
                hintText: localizations.queryVideoPathHint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
