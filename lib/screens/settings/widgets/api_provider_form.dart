import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/model_form.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class APIProviderForm extends StatefulWidget {
  final APIProvider? provider;
  final bool isEditing;
  final ScrollController? scrollController;

  const APIProviderForm(
      {super.key,
      this.provider,
      this.isEditing = false,
      this.scrollController});

  @override
  State<APIProviderForm> createState() => _APIProviderFormState();
}

class _APIProviderFormState extends State<APIProviderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  List<Model> _models = [];
  bool _isApiKeyObscured = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider?.name);
    _baseUrlController = TextEditingController(text: widget.provider?.baseUrl);
    _apiKeyController = TextEditingController(text: widget.provider?.apiKey);
    _models = List.from(widget.provider?.models ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _addOrEditModel({Model? model, int? index}) async {
    HapticService.onButtonPress(context);
    final result = await showBlurredModalBottomSheet<Model>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ModelFormSheet(model: model),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _models[index] = result;
        } else {
          _models.add(result);
        }
      });
    }
  }

  void _deleteModel(int index) {
    HapticService.onButtonPress(context);
    setState(() {
      _models.removeAt(index);
    });
  }

  Future<void> _saveProvider() async {
    HapticService.onButtonPress(context);
    if (_formKey.currentState!.validate()) {
      final manager = Provider.of<APIProviderManager>(context, listen: false);

      if (widget.isEditing) {
        final updatedProvider = widget.provider!.copyWith(
          name: _nameController.text,
          baseUrl: _baseUrlController.text,
          apiKey: _apiKeyController.text,
          models: _models,
        );
        await manager.updateProvider(updatedProvider);
      } else {
        final newProvider = APIProvider(
          name: _nameController.text,
          baseUrl: _baseUrlController.text,
          apiKey: _apiKeyController.text,
          models: _models,
        );
        await manager.addProvider(newProvider);
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
            widget.isEditing
                ? localizations.editProvider
                : localizations.addProvider,
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
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: localizations.providerName),
                      validator: (value) => value!.isEmpty
                          ? localizations.providerNameRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _baseUrlController,
                      decoration:
                          InputDecoration(labelText: localizations.baseUrl),
                      validator: (value) =>
                          value!.isEmpty ? localizations.baseUrlRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: _isApiKeyObscured,
                      decoration: InputDecoration(
                        labelText: localizations.apiKey,
                        suffixIcon: IconButton(
                          icon: Icon(_isApiKeyObscured
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            HapticService.onButtonPress(context);
                            setState(() {
                              _isApiKeyObscured = !_isApiKeyObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? localizations.apiKeyRequired : null,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(localizations.models,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              tooltip: localizations.addModel,
                              onPressed: _addOrEditModel,
                            ),
                          ],
                        ),
                        if (_models.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(localizations.noModelsConfigured),
                          ),
                        ..._models.asMap().entries.map((entry) {
                          final index = entry.key;
                          final model = entry.value;
                          String subtitle;
                          if (model.modelType == ModelType.image) {
                            if (model.imageGenerationMode ==
                                ImageGenerationMode.instant) {
                              subtitle = localizations.imageModeInstant;
                            } else {
                              subtitle = localizations.imageModeAsync;
                              if (model.compatibilityMode ==
                                  CompatibilityMode.midjourneyProxy) {
                                subtitle +=
                                    ' (${localizations.compatibilityModeMidjourney})';
                              }
                            }
                          } else {
                            subtitle =
                                '${localizations.streamable}: ${model.isStreamable ? '✓' : '✗'}';
                          }
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(model.name),
                              subtitle: Text(subtitle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _addOrEditModel(
                                        model: model, index: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteModel(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              bottom: 16.0 + MediaQuery.of(context).padding.bottom,
            ),
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
                  onPressed: _saveProvider,
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
