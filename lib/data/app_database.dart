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
    if (!Hive.isAdapterRegistered(APIProviderAdapter().typeId)) {
      Hive.registerAdapter(APIProviderAdapter());
    }
    if (!Hive.isAdapterRegistered(ModelAdapter().typeId)) {
      Hive.registerAdapter(ModelAdapter());
    }
    if (!Hive.isAdapterRegistered(ChatMessageAdapter().typeId)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    if (!Hive.isAdapterRegistered(ChatSessionAdapter().typeId)) {
      Hive.registerAdapter(ChatSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(SystemPromptTemplateAdapter().typeId)) {
      Hive.registerAdapter(SystemPromptTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(ModelTypeAdapter().typeId)) {
      Hive.registerAdapter(ModelTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(MessageTypeAdapter().typeId)) {
      Hive.registerAdapter(MessageTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(ImageGenerationModeAdapter().typeId)) {
      Hive.registerAdapter(ImageGenerationModeAdapter());
    }
    if (!Hive.isAdapterRegistered(AsyncImageTypeAdapter().typeId)) {
      Hive.registerAdapter(AsyncImageTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(AsyncTaskStatusAdapter().typeId)) {
      Hive.registerAdapter(AsyncTaskStatusAdapter());
    }
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
