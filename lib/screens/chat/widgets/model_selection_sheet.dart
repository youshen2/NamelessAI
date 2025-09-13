import 'package:flutter/material.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class ModelSelectionSheet extends StatefulWidget {
  final APIProvider provider;
  const ModelSelectionSheet({super.key, required this.provider});

  @override
  State<ModelSelectionSheet> createState() => _ModelSelectionSheetState();
}

class _ModelSelectionSheetState extends State<ModelSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Model> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _filteredModels = widget.provider.models;
    _searchController.addListener(_filterModels);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterModels);
    _searchController.dispose();
    super.dispose();
  }

  void _filterModels() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredModels = widget.provider.models.where((model) {
        return model.name.toLowerCase().contains(query);
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
                      localizations.selectAModel,
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
                  hintText: localizations.searchModels,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredModels.isEmpty
                  ? Center(child: Text(localizations.noModelsFound))
                  : ListView.builder(
                      itemCount: _filteredModels.length,
                      itemBuilder: (context, index) {
                        final model = _filteredModels[index];
                        return ListTile(
                          title: Text(model.name),
                          subtitle: Text(
                            model.modelType.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            HapticService.onButtonPress(context);
                            Navigator.of(context).pop(model);
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
