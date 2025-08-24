import 'package:flutter/material.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class ApiPathTemplate {
  final String name;
  final ModelType modelType;
  final ImageGenerationMode? imageGenerationMode;
  final String? chatPath;
  final String? imaginePath;
  final String? fetchPath;
  final String? createVideoPath;
  final String? queryVideoPath;

  ApiPathTemplate({
    required this.name,
    required this.modelType,
    this.imageGenerationMode,
    this.chatPath,
    this.imaginePath,
    this.fetchPath,
    this.createVideoPath,
    this.queryVideoPath,
  });
}

class ApiPathTemplateSelectionSheet extends StatefulWidget {
  final ModelType modelType;
  final ImageGenerationMode imageGenerationMode;

  const ApiPathTemplateSelectionSheet({
    super.key,
    required this.modelType,
    required this.imageGenerationMode,
  });

  @override
  State<ApiPathTemplateSelectionSheet> createState() =>
      _ApiPathTemplateSelectionSheetState();
}

class _ApiPathTemplateSelectionSheetState
    extends State<ApiPathTemplateSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ApiPathTemplate> _filteredTemplates = [];
  late List<ApiPathTemplate> _allTemplates;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allTemplates = _getTemplates(context);
    _filterTemplates();
    _searchController.addListener(_filterTemplates);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTemplates);
    _searchController.dispose();
    super.dispose();
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
        name: localizations.apiPathTemplateQingyunTopVeo,
        modelType: ModelType.video,
        createVideoPath: '/v1/video/create',
        queryVideoPath: '/v1/video/query',
      ),
    ];
  }

  void _filterTemplates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTemplates = _allTemplates.where((template) {
        final typeMatch = template.modelType == widget.modelType;
        final imageModeMatch = widget.modelType != ModelType.image ||
            template.imageGenerationMode == widget.imageGenerationMode;
        final queryMatch =
            query.isEmpty || template.name.toLowerCase().contains(query);
        return typeMatch && imageModeMatch && queryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.apiPathTemplate,
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
                  hintText: localizations.searchApiPathTemplates,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredTemplates.isEmpty
                  ? Center(child: Text(localizations.noApiPathTemplatesFound))
                  : ListView.builder(
                      itemCount: _filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = _filteredTemplates[index];
                        return ListTile(
                          title: Text(template.name),
                          subtitle: Text(
                            [
                              if (template.chatPath != null)
                                'Chat: ${template.chatPath}',
                              if (template.imaginePath != null)
                                'Imagine: ${template.imaginePath}',
                              if (template.fetchPath != null)
                                'Fetch: ${template.fetchPath}',
                              if (template.createVideoPath != null)
                                'Create: ${template.createVideoPath}',
                              if (template.queryVideoPath != null)
                                'Query: ${template.queryVideoPath}',
                            ].join('\n'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(template),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
