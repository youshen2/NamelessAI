import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/services/chatbox_models.dart';

enum ImportMode { merge, replace }

class ImportService {
  Future<ChatBoxBackup?> pickAndParseChatBoxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final filePath = result.files.single.path!;
    final jsonString = await File(filePath).readAsString();
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    return ChatBoxBackup.fromJson(backupData);
  }

  Future<void> importFromChatBox(
    BuildContext context,
    ChatBoxBackup backup,
    ImportMode mode,
    Set<String> selectedCategories,
  ) async {
    if (mode == ImportMode.replace) {
      if (selectedCategories.contains('apiProviders')) {
        await AppDatabase.apiProvidersBox.clear();
      }
      if (selectedCategories.contains('chatSessions')) {
        await AppDatabase.chatSessionsBox.clear();
      }
      if (selectedCategories.contains('systemPromptTemplates')) {
        await AppDatabase.systemPromptTemplatesBox.clear();
      }
    }

    if (selectedCategories.contains('apiProviders')) {
      for (final provider in backup.apiProviders) {
        await AppDatabase.apiProvidersBox.put(provider.id, provider);
      }
    }

    if (selectedCategories.contains('chatSessions')) {
      for (final session in backup.chatSessions) {
        await AppDatabase.chatSessionsBox.put(session.id, session);
      }
    }

    if (selectedCategories.contains('systemPromptTemplates')) {
      for (final template in backup.promptTemplates) {
        await AppDatabase.systemPromptTemplatesBox.put(template.id, template);
      }
    }
  }
}
