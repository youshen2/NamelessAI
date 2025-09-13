import 'package:flutter/material.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/providers/chat_session_manager.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/chat/widgets/template_selection_sheet.dart';
import 'package:nameless_ai/utils/helpers.dart';

class ChatSettingsSheet extends StatefulWidget {
  final ChatSession session;
  final ScrollController scrollController;
  final bool isDialog;

  const ChatSettingsSheet({
    super.key,
    required this.session,
    required this.scrollController,
    this.isDialog = false,
  });

  @override
  State<ChatSettingsSheet> createState() => _ChatSettingsSheetState();
}

class _ChatSettingsSheetState extends State<ChatSettingsSheet> {
  late TextEditingController _systemPromptController;
  late TextEditingController _temperatureController;
  late TextEditingController _topPController;

  late double _temperature;
  late double _topP;
  late bool? _useStreaming;
  late String? _selectedProviderId;
  late String? _selectedModelId;
  late int _maxContextMessages;

  late String _imageSize;
  late String _imageQuality;
  late String _imageStyle;

  @override
  void initState() {
    super.initState();
    _systemPromptController =
        TextEditingController(text: widget.session.systemPrompt);
    _systemPromptController.addListener(() {
      Provider.of<ChatSessionManager>(context, listen: false)
          .updateCurrentSessionDetails(
              systemPrompt: _systemPromptController.text);
    });

    _maxContextMessages = widget.session.maxContextMessages ?? 0;
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
    _temperatureController.dispose();
    _topPController.dispose();
    super.dispose();
  }

  void _showTemplateSelection() async {
    HapticService.onButtonPress(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final selectedPrompt = isDesktop
        ? await showDialog<String>(
            context: context,
            builder: (context) => Dialog(
              child: SizedBox(
                width: 500,
                height: MediaQuery.of(context).size.height * 0.7,
                child: const TemplateSelectionSheet(),
              ),
            ),
          )
        : await showBlurredModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const TemplateSelectionSheet(),
          );

    if (selectedPrompt != null) {
      setState(() {
        _systemPromptController.text = selectedPrompt;
      });
      Provider.of<ChatSessionManager>(context, listen: false)
          .updateCurrentSessionDetails(systemPrompt: selectedPrompt);
    }
  }

  Widget _buildSliderWithTextField({
    required String label,
    required String tooltip,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('$label: ${value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 4),
              Tooltip(
                message: tooltip,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(Icons.help_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  activeTickMarkColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.54),
                  inactiveTickMarkColor: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.54),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: value.toStringAsFixed(2),
                  onChanged: onSliderChanged,
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 70,
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
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final apiManager = Provider.of<APIProviderManager>(context);

    if (apiManager.providers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child:
              Text(localizations.noProvidersAdded, textAlign: TextAlign.center),
        ),
      );
    }

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
        left: widget.isDialog ? 16 : 0,
        right: widget.isDialog ? 16 : 0,
        top: 8,
      ),
      child: Column(
        children: [
          if (!widget.isDialog)
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              localizations.chatSettings,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedProviderId,
                          hint: Text(localizations.apiProviderSettings),
                          isExpanded: true,
                          items: apiManager.providers
                              .map((provider) => DropdownMenuItem(
                                    value: provider.id,
                                    child: Text(provider.name,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            HapticService.onSwitchToggle(context);
                            setState(() {
                              _selectedProviderId = value;
                              _selectedModelId = null;
                            });
                            if (value != null) {
                              final provider = apiManager.providers
                                  .firstWhere((p) => p.id == value);
                              apiManager.setSelectedProvider(provider);
                              Provider.of<ChatSessionManager>(context,
                                      listen: false)
                                  .updateCurrentSessionDetails(
                                providerId: value,
                                modelId: apiManager.selectedModel?.id,
                              );
                            }
                          },
                          decoration: InputDecoration(
                              labelText: localizations.apiProviderSettings),
                        ),
                        const SizedBox(height: 16),
                        if (selectedProvider != null)
                          DropdownButtonFormField<String>(
                            value: _selectedModelId,
                            hint: Text(localizations.modelName),
                            isExpanded: true,
                            items: selectedProvider.models
                                .map((model) => DropdownMenuItem(
                                      value: model.id,
                                      child: Text(model.name,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              HapticService.onSwitchToggle(context);
                              setState(() {
                                _selectedModelId = value;
                              });
                              if (value != null) {
                                final model = selectedProvider!.models
                                    .firstWhere((m) => m.id == value);
                                apiManager.setSelectedModel(model);
                                Provider.of<ChatSessionManager>(context,
                                        listen: false)
                                    .updateCurrentSessionDetails(
                                        modelId: value);
                              }
                            },
                            decoration: InputDecoration(
                                labelText: localizations.modelName),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedModel?.modelType == ModelType.image)
                  _buildImageSettings(localizations, selectedModel)
                else
                  _buildLanguageSettings(localizations),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${localizations.maxContextMessages}: ${_maxContextMessages == 0 ? localizations.unlimited : _maxContextMessages}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(localizations.maxContextMessagesHint,
                            style: Theme.of(context).textTheme.bodySmall),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            inactiveTrackColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            activeTickMarkColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.54),
                            inactiveTickMarkColor: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.54),
                          ),
                          child: Slider(
                            value: _maxContextMessages.toDouble(),
                            min: 0,
                            max: 50,
                            divisions: 50,
                            label: _maxContextMessages == 0
                                ? localizations.unlimited
                                : _maxContextMessages.toString(),
                            onChanged: (value) {
                              HapticService.onSliderChange(context);
                              setState(() {
                                _maxContextMessages = value.round();
                              });
                              Provider.of<ChatSessionManager>(context,
                                      listen: false)
                                  .updateCurrentSessionDetails(
                                      maxContextMessages: value.round());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(localizations.systemPrompt,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  TextButton.icon(
                    onPressed: _showTemplateSelection,
                    icon: const Icon(Icons.library_books_outlined, size: 18),
                    label: Text(localizations.selectTemplate),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _systemPromptController,
                decoration:
                    InputDecoration(hintText: localizations.enterSystemPrompt),
                maxLines: 4,
                minLines: 2,
              ),
            ),
            const SizedBox(height: 24),
            _buildSliderWithTextField(
              label: localizations.temperature,
              tooltip: localizations.temperatureTooltip,
              value: _temperature,
              min: 0.0,
              max: 2.0,
              divisions: 200,
              controller: _temperatureController,
              onSliderChanged: (value) {
                HapticService.onSliderChange(context);
                setState(() {
                  _temperature = value;
                  _temperatureController.text = value.toStringAsFixed(2);
                });
                Provider.of<ChatSessionManager>(context, listen: false)
                    .updateCurrentSessionDetails(temperature: value);
              },
              onTextFieldSubmitted: (text) {
                final value = double.tryParse(text);
                if (value != null) {
                  final clampedValue = value.clamp(0.0, 2.0);
                  setState(() {
                    _temperature = clampedValue;
                    _temperatureController.text =
                        clampedValue.toStringAsFixed(2);
                  });
                  Provider.of<ChatSessionManager>(context, listen: false)
                      .updateCurrentSessionDetails(temperature: clampedValue);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSliderWithTextField(
              label: localizations.topP,
              tooltip: localizations.topPTooltip,
              value: _topP,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              controller: _topPController,
              onSliderChanged: (value) {
                HapticService.onSliderChange(context);
                setState(() {
                  _topP = value;
                  _topPController.text = value.toStringAsFixed(2);
                });
                Provider.of<ChatSessionManager>(context, listen: false)
                    .updateCurrentSessionDetails(topP: value);
              },
              onTextFieldSubmitted: (text) {
                final value = double.tryParse(text);
                if (value != null) {
                  final clampedValue = value.clamp(0.0, 1.0);
                  setState(() {
                    _topP = clampedValue;
                    _topPController.text = clampedValue.toStringAsFixed(2);
                  });
                  Provider.of<ChatSessionManager>(context, listen: false)
                      .updateCurrentSessionDetails(topP: clampedValue);
                }
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.useStreaming,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<bool?>(
                    segments: [
                      ButtonSegment(
                          value: null,
                          label: Text(localizations.streamingDefault)),
                      ButtonSegment(
                          value: true, label: Text(localizations.streamingOn)),
                      ButtonSegment(
                          value: false,
                          label: Text(localizations.streamingOff)),
                    ],
                    selected: {_useStreaming},
                    onSelectionChanged: (selection) {
                      HapticService.onSwitchToggle(context);
                      setState(() {
                        _useStreaming = selection.first;
                      });
                      Provider.of<ChatSessionManager>(context, listen: false)
                          .updateCurrentSessionDetails(
                              useStreaming: selection.first);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSettings(AppLocalizations localizations, Model? model) {
    if (model?.imageGenerationMode == ImageGenerationMode.asynchronous) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _imageSize,
              decoration: InputDecoration(labelText: localizations.imageSize),
              items: ['1024x1024', '1024x1792', '1792x1024']
                  .map((size) =>
                      DropdownMenuItem(value: size, child: Text(size)))
                  .toList(),
              onChanged: (value) {
                HapticService.onSwitchToggle(context);
                if (value != null) {
                  setState(() => _imageSize = value);
                  Provider.of<ChatSessionManager>(context, listen: false)
                      .updateCurrentSessionDetails(imageSize: value);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(localizations.imageQuality,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'standard',
                    label: Text(localizations.qualityStandard)),
                ButtonSegment(
                    value: 'hd', label: Text(localizations.qualityHD)),
              ],
              selected: {_imageQuality},
              onSelectionChanged: (selection) {
                HapticService.onSwitchToggle(context);
                setState(() => _imageQuality = selection.first);
                Provider.of<ChatSessionManager>(context, listen: false)
                    .updateCurrentSessionDetails(imageQuality: selection.first);
              },
            ),
            const SizedBox(height: 24),
            Text(localizations.imageStyle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'vivid', label: Text(localizations.styleVivid)),
                ButtonSegment(
                    value: 'natural', label: Text(localizations.styleNatural)),
              ],
              selected: {_imageStyle},
              onSelectionChanged: (selection) {
                HapticService.onSwitchToggle(context);
                setState(() => _imageStyle = selection.first);
                Provider.of<ChatSessionManager>(context, listen: false)
                    .updateCurrentSessionDetails(imageStyle: selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
