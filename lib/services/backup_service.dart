import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';
import 'package:nameless_ai/services/import_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  Future<void> exportData(BuildContext context,
      {required Map<String, bool> options}) async {
    final backupData = {
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (options['apiProviders'] ?? false) {
      backupData['apiProviders'] =
          AppDatabase.apiProvidersBox.values.map((p) => p.toJson()).toList();
    }
    if (options['chatSessions'] ?? false) {
      backupData['chatSessions'] =
          AppDatabase.chatSessionsBox.values.map((s) => s.toJson()).toList();
    }
    if (options['systemPromptTemplates'] ?? false) {
      backupData['systemPromptTemplates'] = AppDatabase
          .systemPromptTemplatesBox.values
          .map((t) => t.toJson())
          .toList();
    }
    if (options['appConfig'] ?? false) {
      backupData['appConfig'] = AppDatabase.appConfigBox.toMap();
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'NamelessAI_Backup_$timestamp.json';
    final jsonFile = File('${tempDir.path}/$backupFileName');
    await jsonFile.writeAsString(jsonString);

    if (Platform.isAndroid || Platform.isIOS) {
      await Share.shareXFiles([XFile(jsonFile.path, name: backupFileName)]);
    } else {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: backupFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        await jsonFile.copy(result);
      }
    }
  }

  Future<Map<String, dynamic>?> pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final filePath = result.files.single.path!;
    final jsonString = await File(filePath).readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> importNamelessData(
    Map<String, dynamic> backupData,
    ImportMode mode,
    Set<String> categories,
  ) async {
    if (mode == ImportMode.replace) {
      if (categories.contains('apiProviders')) {
        await AppDatabase.apiProvidersBox.clear();
      }
      if (categories.contains('chatSessions')) {
        await AppDatabase.chatSessionsBox.clear();
      }
      if (categories.contains('systemPromptTemplates')) {
        await AppDatabase.systemPromptTemplatesBox.clear();
      }
      if (categories.contains('appConfig')) {
        await AppDatabase.appConfigBox.clear();
      }
    }

    if (categories.contains('apiProviders') &&
        backupData['apiProviders'] != null) {
      final providers = (backupData['apiProviders'] as List)
          .map((p) => APIProvider.fromJson(p))
          .toList();
      for (final provider in providers) {
        await AppDatabase.apiProvidersBox.put(provider.id, provider);
      }
    }

    if (categories.contains('chatSessions') &&
        backupData['chatSessions'] != null) {
      final sessions = (backupData['chatSessions'] as List)
          .map((s) => ChatSession.fromJson(s))
          .toList();
      for (final session in sessions) {
        await AppDatabase.chatSessionsBox.put(session.id, session);
      }
    }

    if (categories.contains('systemPromptTemplates') &&
        backupData['systemPromptTemplates'] != null) {
      final templates = (backupData['systemPromptTemplates'] as List)
          .map((t) => SystemPromptTemplate.fromJson(t))
          .toList();
      for (final template in templates) {
        await AppDatabase.systemPromptTemplatesBox.put(template.id, template);
      }
    }

    if (categories.contains('appConfig') && backupData['appConfig'] != null) {
      final config = backupData['appConfig'] as Map;
      for (final entry in config.entries) {
        await AppDatabase.appConfigBox.put(entry.key, entry.value);
      }
    }
  }
}
