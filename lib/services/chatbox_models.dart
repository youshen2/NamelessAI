import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/models/system_prompt_template.dart';

class ChatBoxBackup {
  final List<ChatSession> chatSessions;
  final List<SystemPromptTemplate> promptTemplates;
  final List<APIProvider> apiProviders;
  final Map<String, dynamic> settings;
  final List<String> unsupportedItems;

  ChatBoxBackup({
    required this.chatSessions,
    required this.promptTemplates,
    required this.apiProviders,
    required this.settings,
    required this.unsupportedItems,
  });

  factory ChatBoxBackup.fromJson(Map<String, dynamic> json) {
    final List<ChatSession> sessions = [];
    final List<SystemPromptTemplate> templates = [];
    final List<APIProvider> providers = [];
    final List<String> unsupported = [];

    final sessionList = json['chat-sessions-list'] as List<dynamic>? ?? [];
    for (var sessionMeta in sessionList) {
      final sessionId = sessionMeta['id'];
      final sessionData = json['session:$sessionId'] as Map<String, dynamic>?;
      if (sessionData != null) {
        final allMessagesData = sessionData['messages'] as List<dynamic>? ?? [];
        String? systemPrompt;

        final systemMessageData = allMessagesData
            .firstWhere((msg) => msg['role'] == 'system', orElse: () => null);

        if (systemMessageData != null) {
          final contentParts =
              systemMessageData['contentParts'] as List<dynamic>? ?? [];
          if (contentParts.isNotEmpty) {
            systemPrompt = contentParts.first['text'] as String? ?? '';
          }
        }

        final messages = allMessagesData
            .where((msg) => msg['role'] != 'system')
            .map((msg) => _parseChatMessage(msg))
            .toList();

        final branches = <String, List<List<ChatMessage>>>{};
        final activeBranchSelections = <String, int>{};
        final messageForksHash =
            sessionData['messageForksHash'] as Map<String, dynamic>? ?? {};

        messageForksHash.forEach((messageId, forkData) {
          final forkLists = forkData['lists'] as List<dynamic>? ?? [];
          final position = forkData['position'] as int? ?? 0;

          final List<List<ChatMessage>> messageBranches = [];
          for (var branchData in forkLists) {
            final branchMessages =
                (branchData['messages'] as List<dynamic>? ?? [])
                    .map((msg) => _parseChatMessage(msg))
                    .toList();
            messageBranches.add(branchMessages);
          }
          branches[messageId] = messageBranches;
          activeBranchSelections[messageId] = position;
        });

        sessions.add(ChatSession(
          id: sessionId,
          name: sessionMeta['name'],
          messages: messages,
          systemPrompt: systemPrompt,
          branches: branches,
          activeBranchSelections: activeBranchSelections,
        ));
      }
    }

    final copilots = json['myCopilots'] as List<dynamic>? ?? [];
    for (var copilot in copilots) {
      templates.add(SystemPromptTemplate(
        name: copilot['name'],
        prompt: copilot['prompt'],
      ));
    }

    final settings = json['settings'] as Map<String, dynamic>? ?? {};
    final customProvidersMeta =
        settings['customProviders'] as List<dynamic>? ?? [];
    final providersData = settings['providers'] as Map<String, dynamic>? ?? {};

    for (var providerMeta in customProvidersMeta) {
      final providerId = providerMeta['id'] as String?;
      if (providerId != null && providersData.containsKey(providerId)) {
        final providerDetails =
            providersData[providerId] as Map<String, dynamic>;
        final providerModels =
            providerDetails['models'] as List<dynamic>? ?? [];

        final List<Model> models = providerModels.map((modelData) {
          return Model(
            name: modelData['modelId'],
            isStreamable: true,
            modelType: ModelType.language,
            chatPath: '/v1/chat/completions',
          );
        }).toList();

        String baseUrl = providerDetails['apiHost'];
        if (baseUrl.endsWith('/v1')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 3);
        }
        while (baseUrl.endsWith('/')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
        }

        providers.add(APIProvider(
          id: providerId,
          name: providerMeta['name'],
          baseUrl: baseUrl,
          apiKey: providerDetails['apiKey'],
          models: models,
        ));
      }
    }

    if (json.containsKey('key')) {
      unsupported.add('API Keys (Global)');
    }

    return ChatBoxBackup(
      chatSessions: sessions,
      promptTemplates: templates,
      apiProviders: providers,
      settings: settings,
      unsupportedItems: unsupported,
    );
  }

  static ChatMessage _parseChatMessage(Map<String, dynamic> msg) {
    final contentParts = msg['contentParts'] as List<dynamic>? ?? [];
    final content = contentParts.isNotEmpty
        ? (contentParts.first['text'] as String? ?? '')
        : '';
    return ChatMessage(
      id: msg['id'],
      role: msg['role'],
      content: content,
      timestamp: DateTime.fromMillisecondsSinceEpoch(msg['timestamp']),
      modelName: msg['model'],
    );
  }
}
