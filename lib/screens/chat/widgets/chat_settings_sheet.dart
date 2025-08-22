import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/data/providers/system_prompt_template_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/utils/helpers.dart';
import 'package:nameless_ai/widgets/responsive_layout.dart';

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
  late double _temperature;
  late double _topP;
  late bool? _useStreaming;
  late String? _selectedProviderId;
  late String? _selectedModelId;

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
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    _maxContextController.dispose();
    super.dispose();
  }

  void _showTemplateSelection() async {
    final manager =
        Provider.of<SystemPromptTemplateManager>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    if (manager.templates.isEmpty) {
      showSnackBar(context, localizations.noSystemPromptTemplates);
      return;
    }

    final selectedPrompt = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _TemplateSelectionScreen(
          scrollController: scrollController,
        ),
      ),
    );

    if (selectedPrompt != null) {
      setState(() {
        _systemPromptController.text = selectedPrompt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final apiManager = Provider.of<APIProviderManager>(context);

    final selectedProvider = _selectedProviderId != null
        ? apiManager.providers.firstWhere((p) => p.id == _selectedProviderId,
            orElse: () => apiManager.providers.first)
        : null;

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
                  decoration: InputDecoration(
                      hintText: localizations.enterSystemPrompt),
                  maxLines: 4,
                  minLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                    '${localizations.temperature}: ${_temperature.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: _temperature,
                  min: 0.0,
                  max: 2.0,
                  divisions: 200,
                  label: _temperature.toStringAsFixed(2),
                  onChanged: (value) {
                    setState(() {
                      _temperature = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('${localizations.topP}: ${_topP.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: _topP,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  label: _topP.toStringAsFixed(2),
                  onChanged: (value) {
                    setState(() {
                      _topP = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
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
                    widget.onSave({
                      'providerId': _selectedProviderId,
                      'modelId': _selectedModelId,
                      'systemPrompt': _systemPromptController.text,
                      'temperature': _temperature,
                      'topP': _topP,
                      'useStreaming': _useStreaming,
                      'maxContextMessages': maxContext == 0 ? null : maxContext,
                    });
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
}

class _TemplateSelectionScreen extends StatefulWidget {
  final ScrollController scrollController;
  const _TemplateSelectionScreen({required this.scrollController});

  @override
  State<_TemplateSelectionScreen> createState() =>
      __TemplateSelectionScreenState();
}

class __TemplateSelectionScreenState extends State<_TemplateSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SystemPromptTemplate> _filteredTemplates = [];

  @override
  void initState() {
    super.initState();
    final manager =
        Provider.of<SystemPromptTemplateManager>(context, listen: false);
    _filteredTemplates = manager.templates;
    _searchController.addListener(_filterTemplates);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTemplates);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTemplates() {
    final manager =
        Provider.of<SystemPromptTemplateManager>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTemplates = manager.templates.where((template) {
        return template.name.toLowerCase().contains(query) ||
            template.prompt.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.selectTemplate,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchTemplates,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredTemplates.isEmpty
                ? Center(child: Text(localizations.noTemplatesFound))
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _filteredTemplates[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(template.name),
                          subtitle: Text(
                            template.prompt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () =>
                              Navigator.of(context).pop(template.prompt),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
