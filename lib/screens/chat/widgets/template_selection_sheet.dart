import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/data/providers/system_prompt_template_manager.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:nameless_ai/utils/helpers.dart';

class TemplateSelectionSheet extends StatefulWidget {
  const TemplateSelectionSheet({super.key});

  @override
  State<TemplateSelectionSheet> createState() => _TemplateSelectionSheetState();
}

class _TemplateSelectionSheetState extends State<TemplateSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<SystemPromptTemplate> _filteredTemplates = [];

  @override
  void initState() {
    super.initState();
    final manager =
        Provider.of<SystemPromptTemplateManager>(context, listen: false);
    if (manager.templates.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showSnackBar(
              context, AppLocalizations.of(context)!.noSystemPromptTemplates);
          Navigator.of(context).pop();
        }
      });
    }
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    onPressed: () {
                      HapticService.onButtonPress(context);
                      Navigator.of(context).pop();
                    },
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
            const SizedBox(height: 8),
            Expanded(
              child: _filteredTemplates.isEmpty
                  ? Center(child: Text(localizations.noTemplatesFound))
                  : ListView.builder(
                      itemCount: _filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = _filteredTemplates[index];
                        return ListTile(
                          title: Text(template.name),
                          subtitle: Text(
                            template.prompt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            HapticService.onButtonPress(context);
                            Navigator.of(context).pop(template.prompt);
                          },
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
