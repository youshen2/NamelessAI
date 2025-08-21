import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';

class SystemPromptTemplateManager extends ChangeNotifier {
  List<SystemPromptTemplate> _templates = [];

  SystemPromptTemplateManager() {
    _loadTemplates();
  }

  List<SystemPromptTemplate> get templates => _templates;

  void _loadTemplates() {
    _templates = AppDatabase.systemPromptTemplatesBox.values.toList();
    notifyListeners();
  }

  Future<void> addTemplate(SystemPromptTemplate template) async {
    await AppDatabase.systemPromptTemplatesBox.put(template.id, template);
    _loadTemplates();
  }

  Future<void> updateTemplate(SystemPromptTemplate template) async {
    await template.save();
    _loadTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    await AppDatabase.systemPromptTemplatesBox.delete(id);
    _loadTemplates();
  }
}
