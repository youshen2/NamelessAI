import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/screens/settings/widgets/model_form.dart';

class APIProviderForm extends StatefulWidget {
  final APIProvider? provider;
  final ScrollController? scrollController;

  const APIProviderForm({super.key, this.provider, this.scrollController});

  @override
  State<APIProviderForm> createState() => _APIProviderFormState();
}

class _APIProviderFormState extends State<APIProviderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _chatPathController;
  List<Model> _models = [];
  bool _isApiKeyObscured = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider?.name);
    _baseUrlController = TextEditingController(text: widget.provider?.baseUrl);
    _apiKeyController = TextEditingController(text: widget.provider?.apiKey);
    _chatPathController = TextEditingController(
        text: widget.provider?.chatCompletionPath ?? '/v1/chat/completions');
    _models = List.from(widget.provider?.models ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _chatPathController.dispose();
    super.dispose();
  }

  void _addOrEditModel({Model? model, int? index}) async {
    final result = await showModalBottomSheet<Model>(
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
    setState(() {
      _models.removeAt(index);
    });
  }

  Future<void> _saveProvider() async {
    if (_formKey.currentState!.validate()) {
      final manager = Provider.of<APIProviderManager>(context, listen: false);
      final newProvider = APIProvider(
        id: widget.provider?.id,
        name: _nameController.text,
        baseUrl: _baseUrlController.text,
        apiKey: _apiKeyController.text,
        chatCompletionPath: _chatPathController.text,
        models: _models,
      );

      if (widget.provider == null) {
        await manager.addProvider(newProvider);
      } else {
        await manager.updateProvider(newProvider);
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
            widget.provider == null
                ? localizations.addProvider
                : localizations.editProvider,
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
                            setState(() {
                              _isApiKeyObscured = !_isApiKeyObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? localizations.apiKeyRequired : null,
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text(localizations.advancedSettings,
                          style: Theme.of(context).textTheme.titleSmall),
                      initiallyExpanded: false,
                      childrenPadding: const EdgeInsets.only(top: 8),
                      children: [
                        TextFormField(
                          controller: _chatPathController,
                          decoration: InputDecoration(
                              labelText: localizations.chatPath),
                          validator: (value) => value!.isEmpty
                              ? localizations.chatPathRequired
                              : null,
                        ),
                      ],
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
                            subtitle = model.imageGenerationMode ==
                                    ImageGenerationMode.instant
                                ? localizations.imageModeInstant
                                : localizations.imageModeAsync;
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
