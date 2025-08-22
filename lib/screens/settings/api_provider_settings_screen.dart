import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/utils/helpers.dart';

class APIProviderSettingsScreen extends StatefulWidget {
  const APIProviderSettingsScreen({super.key});

  @override
  State<APIProviderSettingsScreen> createState() =>
      _APIProviderSettingsScreenState();
}

class _APIProviderSettingsScreenState extends State<APIProviderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.apiProviderSettings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: localizations.addProvider,
            onPressed: () => _showProviderForm(context),
          ),
        ],
      ),
      body: Consumer<APIProviderManager>(
        builder: (context, manager, child) {
          if (manager.providers.isEmpty) {
            return Center(
              child: Text(localizations.noProvidersAdded),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: manager.providers.length,
            itemBuilder: (context, index) {
              final provider = manager.providers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(provider.baseUrl,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      Text('${localizations.models}:',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (provider.models.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(localizations.noModelsConfigured,
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                        ),
                      ...provider.models.map((model) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text(
                                '- ${model.name} (Stream: ${model.isStreamable ? '✓' : '✗'}, Thinking: ${model.supportsThinking ? '✓' : '✗'})'),
                          )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: localizations.editProvider,
                            onPressed: () =>
                                _showProviderForm(context, provider: provider),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: localizations.delete,
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                  context, localizations.apiProviderSettings);
                              if (confirmed == true) {
                                await manager.deleteProvider(provider.id);
                                showSnackBar(context,
                                    localizations.itemDeleted(provider.name));
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

  void _showProviderForm(BuildContext context, {APIProvider? provider}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return APIProviderForm(
              provider: provider,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}

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
        child: _ModelFormSheet(model: model),
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
                    TextFormField(
                      controller: _chatPathController,
                      decoration:
                          InputDecoration(labelText: localizations.chatPath),
                      validator: (value) => value!.isEmpty
                          ? localizations.chatPathRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text(localizations.models,
                          style: Theme.of(context).textTheme.titleMedium),
                      initiallyExpanded: true,
                      children: [
                        if (_models.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(localizations.noModelsConfigured),
                          ),
                        ..._models.asMap().entries.map((entry) {
                          final index = entry.key;
                          final model = entry.value;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(model.name),
                              subtitle: Text(
                                  'Stream: ${model.isStreamable ? '✓' : '✗'}, Thinking: ${model.supportsThinking ? '✓' : '✗'}'),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _addOrEditModel,
                            icon: const Icon(Icons.add),
                            label: Text(localizations.addModel),
                          ),
                        ),
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

class _ModelFormSheet extends StatefulWidget {
  final Model? model;
  const _ModelFormSheet({this.model});

  @override
  State<_ModelFormSheet> createState() => _ModelFormSheetState();
}

class _ModelFormSheetState extends State<_ModelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _modelNameController;
  late TextEditingController _maxTokensController;
  late bool _isStreamable;
  late bool _supportsThinking;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController(text: widget.model?.name);
    _maxTokensController =
        TextEditingController(text: widget.model?.maxTokens?.toString() ?? '');
    _isStreamable = widget.model?.isStreamable ?? true;
    _supportsThinking = widget.model?.supportsThinking ?? false;
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
      );
      Navigator.pop(context, newModel);
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
                  : localizations.editProvider,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
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
