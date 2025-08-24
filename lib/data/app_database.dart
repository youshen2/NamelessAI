import 'package:hive_flutter/hive_flutter.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';

class AppDatabase {
  static const String _apiProvidersBox = 'apiProviders';
  static const String _chatSessionsBox = 'chatSessions';
  static const String _systemPromptTemplatesBox = 'systemPromptTemplates';
  static const String _appConfigBox = 'appConfig';

  static late Box<APIProvider> apiProvidersBox;
  static late Box<ChatSession> chatSessionsBox;
  static late Box<SystemPromptTemplate> systemPromptTemplatesBox;
  static late Box appConfigBox;

  static Future<void> registerAdapters() async {
    Hive.registerAdapter(APIProviderAdapter());
    Hive.registerAdapter(ModelAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(ChatSessionAdapter());
    Hive.registerAdapter(SystemPromptTemplateAdapter());
    Hive.registerAdapter(ModelTypeAdapter());
  }

  static Future<void> openBoxes() async {
    apiProvidersBox = await Hive.openBox<APIProvider>(_apiProvidersBox);
    chatSessionsBox = await Hive.openBox<ChatSession>(_chatSessionsBox);
    systemPromptTemplatesBox =
        await Hive.openBox<SystemPromptTemplate>(_systemPromptTemplatesBox);
    appConfigBox = await Hive.openBox(_appConfigBox);
  }

  static Future<void> closeBoxes() async {
    await apiProvidersBox.close();
    await chatSessionsBox.close();
    await systemPromptTemplatesBox.close();
    await appConfigBox.close();
  }

  static Future<void> clearAllData() async {
    await apiProvidersBox.clear();
    await chatSessionsBox.clear();
    await systemPromptTemplatesBox.clear();
    await appConfigBox.clear();
  }

  static Future<void> reinitialize() async {
    await closeBoxes();
    await registerAdapters();
    await openBoxes();
  }
}
