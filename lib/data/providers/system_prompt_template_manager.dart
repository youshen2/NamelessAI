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
    _templates.add(template);
    notifyListeners();
  }

  Future<void> updateTemplate(SystemPromptTemplate template) async {
    await template.save();
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _templates[index] = template;
    }
    notifyListeners();
  }

  Future<void> deleteTemplate(String id) async {
    await AppDatabase.systemPromptTemplatesBox.delete(id);
    _templates.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
