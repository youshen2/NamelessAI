import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/template_selection_sheet.dart';
import 'package:nameless_ai/utils/helpers.dart';

class ChatSettingsSheet extends StatefulWidget {
  final ChatSession session;
  final Function(Map<String, dynamic>) onSave;
  final ScrollController scrollController;

  const ChatSettingsSheet({
    super.key,
    required this.session,
    required this.onSave,
    required this.scrollController,
  });

  @override
  State<ChatSettingsSheet> createState() => _ChatSettingsSheetState();
}

class _ChatSettingsSheetState extends State<ChatSettingsSheet> {
  late TextEditingController _systemPromptController;
  late TextEditingController _maxContextController;
  late TextEditingController _temperatureController;
  late TextEditingController _topPController;

  late double _temperature;
  late double _topP;
  late bool? _useStreaming;
  late String? _selectedProviderId;
  late String? _selectedModelId;

  late String _imageSize;
  late String _imageQuality;
  late String _imageStyle;

  @override
  void initState() {
    super.initState();
    _systemPromptController =
        TextEditingController(text: widget.session.systemPrompt);
    _maxContextController = TextEditingController(
        text: widget.session.maxContextMessages?.toString() ?? '');
    _temperature = widget.session.temperature;
    _topP = widget.session.topP;
    _useStreaming = widget.session.useStreaming;
    _selectedProviderId = widget.session.providerId;
    _selectedModelId = widget.session.modelId;

    _temperatureController =
        TextEditingController(text: _temperature.toStringAsFixed(2));
    _topPController = TextEditingController(text: _topP.toStringAsFixed(2));

    _imageSize = widget.session.imageSize ?? '1024x1024';
    _imageQuality = widget.session.imageQuality ?? 'standard';
    _imageStyle = widget.session.imageStyle ?? 'vivid';
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    _maxContextController.dispose();
    _temperatureController.dispose();
    _topPController.dispose();
    super.dispose();
  }

  void _showTemplateSelection() async {
    final selectedPrompt = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TemplateSelectionSheet(),
    );

    if (selectedPrompt != null) {
      setState(() {
        _systemPromptController.text = selectedPrompt;
      });
    }
  }

  Widget _buildSliderWithTextField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required TextEditingController controller,
    required ValueChanged<double> onSliderChanged,
    required ValueChanged<String> onTextFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: value.toStringAsFixed(2),
                onChanged: onSliderChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onFieldSubmitted: onTextFieldSubmitted,
                onTapOutside: (_) => onTextFieldSubmitted(controller.text),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final apiManager = Provider.of<APIProviderManager>(context);

    APIProvider? selectedProvider;
    if (_selectedProviderId != null) {
      try {
        selectedProvider = apiManager.providers.firstWhere(
          (p) => p.id == _selectedProviderId,
        );
      } catch (e) {
        selectedProvider = null;
        _selectedModelId = null;
      }
    }

    if (selectedProvider == null && apiManager.providers.isNotEmpty) {
      selectedProvider = apiManager.providers.first;
      _selectedProviderId = selectedProvider.id;
      _selectedModelId = null;
    }

    Model? selectedModel;
    if (_selectedModelId != null && selectedProvider != null) {
      try {
        selectedModel = selectedProvider.models.firstWhere(
          (m) => m.id == _selectedModelId,
        );
      } catch (e) {
        selectedModel = null;
      }
    }

    if (selectedModel == null &&
        selectedProvider != null &&
        selectedProvider.models.isNotEmpty) {
      selectedModel = selectedProvider.models.first;
      _selectedModelId = selectedModel.id;
    }

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
            localizations.chatSettings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                Text(localizations.modelSelection,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProviderId,
                  hint: Text(localizations.apiProviderSettings),
                  items: apiManager.providers
                      .map((provider) => DropdownMenuItem(
                            value: provider.id,
                            child: Text(provider.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProviderId = value;
                      _selectedModelId = null;
                    });
                  },
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: 16),
                if (selectedProvider != null)
                  DropdownButtonFormField<String>(
                    value: _selectedModelId,
                    hint: Text(localizations.modelName),
                    items: selectedProvider.models
                        .map((model) => DropdownMenuItem(
                              value: model.id,
                              child: Text(model.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedModelId = value;
                      });
                    },
                    decoration: const InputDecoration(),
                  ),
                const SizedBox(height: 24),
                if (selectedModel?.modelType == ModelType.image)
                  _buildImageSettings(localizations, selectedModel)
                else
                  _buildLanguageSettings(localizations),
                const Divider(height: 32),
                Text(localizations.maxContextMessages,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _maxContextController,
                  decoration: InputDecoration(
                    hintText: localizations.maxContextMessagesHint,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final maxContext = int.tryParse(_maxContextController.text);
                    final settings = {
                      'providerId': _selectedProviderId,
                      'modelId': _selectedModelId,
                      'maxContextMessages': maxContext == 0 ? null : maxContext,
                    };

                    if (selectedModel?.modelType == ModelType.image) {
                      settings.addAll({
                        'imageSize': _imageSize,
                        'imageQuality': _imageQuality,
                        'imageStyle': _imageStyle,
                      });
                    } else {
                      settings.addAll({
                        'systemPrompt': _systemPromptController.text,
                        'temperature': _temperature,
                        'topP': _topP,
                        'useStreaming': _useStreaming,
                      });
                    }
                    widget.onSave(settings);
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(localizations.systemPrompt,
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: _showTemplateSelection,
              icon: const Icon(Icons.library_books_outlined, size: 18),
              label: Text(localizations.selectTemplate),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _systemPromptController,
          decoration:
              InputDecoration(hintText: localizations.enterSystemPrompt),
          maxLines: 4,
          minLines: 2,
        ),
        const SizedBox(height: 24),
        _buildSliderWithTextField(
          label: localizations.temperature,
          value: _temperature,
          min: 0.0,
          max: 2.0,
          divisions: 200,
          controller: _temperatureController,
          onSliderChanged: (value) {
            setState(() {
              _temperature = value;
              _temperatureController.text = value.toStringAsFixed(2);
            });
          },
          onTextFieldSubmitted: (text) {
            final value = double.tryParse(text);
            if (value != null) {
              setState(() {
                _temperature = value.clamp(0.0, 2.0);
                _temperatureController.text = _temperature.toStringAsFixed(2);
              });
            }
          },
        ),
        const SizedBox(height: 24),
        _buildSliderWithTextField(
          label: localizations.topP,
          value: _topP,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          controller: _topPController,
          onSliderChanged: (value) {
            setState(() {
              _topP = value;
              _topPController.text = value.toStringAsFixed(2);
            });
          },
          onTextFieldSubmitted: (text) {
            final value = double.tryParse(text);
            if (value != null) {
              setState(() {
                _topP = value.clamp(0.0, 1.0);
                _topPController.text = _topP.toStringAsFixed(2);
              });
            }
          },
        ),
        const SizedBox(height: 24),
        Text(localizations.useStreaming,
            style: Theme.of(context).textTheme.titleMedium),
        DropdownButtonFormField<bool?>(
          value: _useStreaming,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                  '${localizations.streamingDefault} (${localizations.overrideModelSettings})'),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(localizations.streamingOn),
            ),
            DropdownMenuItem(
              value: false,
              child: Text(localizations.streamingOff),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _useStreaming = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildImageSettings(AppLocalizations localizations, Model? model) {
    if (model?.imageGenerationMode == ImageGenerationMode.asynchronous) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.imageSize,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _imageSize,
          items: ['1024x1024', '1024x1792', '1792x1024']
              .map((size) => DropdownMenuItem(value: size, child: Text(size)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _imageSize = value);
          },
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        Text(localizations.imageQuality,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _imageQuality,
          items: [
            DropdownMenuItem(
                value: 'standard', child: Text(localizations.qualityStandard)),
            DropdownMenuItem(value: 'hd', child: Text(localizations.qualityHD)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _imageQuality = value);
          },
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        Text(localizations.imageStyle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _imageStyle,
          items: [
            DropdownMenuItem(
                value: 'vivid', child: Text(localizations.styleVivid)),
            DropdownMenuItem(
                value: 'natural', child: Text(localizations.styleNatural)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _imageStyle = value);
          },
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
