import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/api_service.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/data/providers/api_provider_manager.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/generation_service.dart';
import 'package:nameless_ai/services/notification_service.dart';

class ChatSessionManager extends ChangeNotifier {
  static const String _defaultSystemPrompt = "You are a helpful assistant.";
  static const double _defaultTemperature = 0.7;
  static const double _defaultTopP = 1.0;
  static const String _defaultImageSize = '1024x1024';
  static const String _defaultImageQuality = 'standard';
  static const String _defaultImageStyle = 'vivid';

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isNewSession = true;
  bool shouldScrollToBottomOnLoad = true;
  final Set<String> _generatingSessions = {};
  final Map<String, CancelToken> _cancelTokens = {};
  APIProviderManager? _apiProviderManager;
  Timer? _refreshTimer;

  ChatSessionManager() {
    _loadSessions();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  bool get isNewSession => _isNewSession;
  bool get isGenerating =>
      _currentSession != null &&
      _generatingSessions.contains(_currentSession!.id);
  Set<String> get generatingSessions => _generatingSessions;

  List<ChatMessage> get activeMessages {
    if (_currentSession == null) return [];
    return _currentSession!.activeMessages;
  }

  void setApiProviderManager(APIProviderManager manager) {
    _apiProviderManager = manager;
  }

  void _loadSessions() {
    _sessions = AppDatabase.chatSessionsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<void> loadLastSession() async {
    _loadSessions();
    if (_sessions.isNotEmpty) {
      final lastSessionId = AppDatabase.appConfigBox.get('lastActiveSessionId');
      if (lastSessionId != null) {
        final session = AppDatabase.chatSessionsBox.get(lastSessionId);
        if (session != null) {
          _currentSession = session;
          _isNewSession = false;
          shouldScrollToBottomOnLoad = false;
          notifyListeners();
          return;
        }
      }
      _currentSession = _sessions.first;
      _isNewSession = false;
      shouldScrollToBottomOnLoad = false;
      notifyListeners();
    }
  }

  void _saveCurrentSessionId() {
    if (_currentSession != null && !_isNewSession) {
      AppDatabase.appConfigBox.put('lastActiveSessionId', _currentSession!.id);
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    final intervalSeconds = AppDatabase.appConfigBox
        .get('asyncTaskRefreshInterval', defaultValue: 10);
    if (intervalSeconds > 0) {
      _refreshTimer = Timer.periodic(
          Duration(seconds: intervalSeconds), (timer) => _periodicRefresh());
    }
  }

  Future<void> _periodicRefresh() async {
    if (_apiProviderManager == null) return;

    final allProviders = _apiProviderManager!.providers;
    if (allProviders.isEmpty) return;

    for (final session in _sessions) {
      for (final message in session.messages) {
        if (message.taskId != null &&
            (message.asyncTaskStatus == AsyncTaskStatus.inProgress ||
                message.asyncTaskStatus == AsyncTaskStatus.submitted)) {
          final provider = allProviders.firstWhere(
            (p) => p.id == session.providerId,
            orElse: () => allProviders.first,
          );
          final model = provider.models.firstWhere(
            (m) => m.id == session.modelId,
            orElse: () => provider.models.first,
          );

          if (model.imageGenerationMode == ImageGenerationMode.asynchronous ||
              model.modelType == ModelType.video) {
            await refreshAsyncTaskStatus(message.id, provider, model);
          }
        }
      }
    }
  }

  void startNewSession(
      {String? providerId, String? modelId, String? systemPrompt}) {
    _currentSession = ChatSession(
      name: "New Chat ${DateTime.now().millisecondsSinceEpoch}",
      providerId: providerId,
      modelId: modelId,
      systemPrompt: systemPrompt ?? _defaultSystemPrompt,
      temperature: _defaultTemperature,
      topP: _defaultTopP,
      imageSize: _defaultImageSize,
      imageQuality: _defaultImageQuality,
      imageStyle: _defaultImageStyle,
    );
    _isNewSession = true;
    shouldScrollToBottomOnLoad = true;
    notifyListeners();
  }

  void loadSession(String sessionId) {
    final session = AppDatabase.chatSessionsBox.get(sessionId);
    if (session != null) {
      _currentSession = session;
      _isNewSession = false;
      _saveCurrentSessionId();
      shouldScrollToBottomOnLoad = true;
      notifyListeners();
    }
  }

  Future<void> saveCurrentSession(String name) async {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );

    await AppDatabase.chatSessionsBox
        .put(_currentSession!.id, _currentSession!);
    _loadSessions();
    _isNewSession = false;
    _saveCurrentSessionId();
    notifyListeners();
  }

  Future<void> renameSession(String sessionId, String newName) async {
    final session = AppDatabase.chatSessionsBox.get(sessionId);
    if (session != null) {
      session.name = newName;
      session.updatedAt = DateTime.now();
      await session.save();
      _loadSessions();
    }
  }

  Future<void> updateCurrentSession(ChatSession session) async {
    _currentSession = session.copyWith(updatedAt: DateTime.now());
    if (!_isNewSession || session.messages.isNotEmpty) {
      await AppDatabase.chatSessionsBox.put(session.id, _currentSession!);
      _loadSessions();
    }
    notifyListeners();
  }

  Future<void> updateCurrentSessionDetails({
    String? providerId,
    String? modelId,
    String? systemPrompt,
    double? temperature,
    double? topP,
    bool? useStreaming,
    int? maxContextMessages,
    String? imageSize,
    String? imageQuality,
    String? imageStyle,
  }) async {
    if (_currentSession == null) return;

    final sessionToUpdate = _currentSession!;
    var updatedSession = sessionToUpdate.copyWith(
      providerId: providerId,
      modelId: modelId,
      systemPrompt: systemPrompt,
      temperature: temperature,
      topP: topP,
      imageSize: imageSize,
      imageQuality: imageQuality,
      imageStyle: imageStyle,
    );

    updatedSession.useStreaming = useStreaming;
    updatedSession.maxContextMessages = maxContextMessages;

    await updateCurrentSession(updatedSession);
  }

  Future<void> deleteSession(String sessionId) async {
    await AppDatabase.chatSessionsBox.delete(sessionId);
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
      _isNewSession = true;
    }
    _loadSessions();
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await AppDatabase.chatSessionsBox.clear();
    _loadSessions();
    startNewSession(
      providerId: _apiProviderManager?.selectedProvider?.id,
      modelId: _apiProviderManager?.selectedModel?.id,
    );
    notifyListeners();
  }

  void updateMessageInCurrentSession(String messageId, String newContent) {
    if (_currentSession == null) return;
    final message = _findMessageInSession(_currentSession!, messageId);
    if (message != null) {
      message.content = newContent;
      updateCurrentSession(_currentSession!);
    }
  }

  void deleteMessageFromCurrentSession(String messageId) {
    if (_currentSession == null) return;
    bool removed = _removeMessageInSession(_currentSession!, messageId);
    if (removed) {
      final session = _currentSession!;
      final branches = session.branches;
      final keysToRemove = <String>[];

      branches.forEach((key, branchList) {
        branchList.removeWhere((branch) => branch.isEmpty);

        if (branchList.isEmpty) {
          keysToRemove.add(key);
        } else {
          final activeSelection = session.activeBranchSelections[key] ?? 0;
          if (activeSelection >= branchList.length) {
            session.activeBranchSelections[key] = branchList.length - 1;
          }
        }
      });

      for (final key in keysToRemove) {
        branches.remove(key);
        session.activeBranchSelections.remove(key);
      }

      updateCurrentSession(session);
    }
  }

  Future<void> sendMessage(String text, APIProvider provider, Model model,
      AppLocalizations localizations) async {
    if (isGenerating) return;

    if (_currentSession == null) {
      startNewSession(providerId: provider.id, modelId: model.id);
    }

    if (model.modelType != ModelType.language &&
        model.modelType != ModelType.image &&
        model.modelType != ModelType.video) {
      if (_isNewSession) {
        await saveCurrentSession(_currentSession!.name);
      }
      final userMessage =
          ChatMessage(role: 'user', content: text, modelName: model.name);
      _addMessageToActivePath(_currentSession!, userMessage);

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: localizations.unsupportedModelTypeInChat,
        isLoading: false,
        isError: true,
        modelName: model.name,
      );
      _addMessageToActivePath(_currentSession!, assistantMessage);
      await updateCurrentSession(_currentSession!);
      return;
    }

    if (_isNewSession) {
      await saveCurrentSession(_currentSession!.name);
    }

    final sessionId = _currentSession!.id;

    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      modelName: model.name,
    );
    _addMessageToActivePath(_currentSession!, userMessage);

    MessageType messageType;
    switch (model.modelType) {
      case ModelType.image:
        messageType = MessageType.image;
        break;
      case ModelType.video:
        messageType = MessageType.video;
        break;
      default:
        messageType = MessageType.text;
    }

    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: '',
      isLoading: true,
      modelName: model.name,
      messageType: messageType,
    );
    _addMessageToActivePath(_currentSession!, assistantMessage);

    _generatingSessions.add(sessionId);
    notifyListeners();

    _performGeneration(
        sessionId, assistantMessage.id, provider, model, localizations);
  }

  (List<ChatMessage>, int)? _findMessageAndParentListInSession(
      ChatSession session, String messageId) {
    (List<ChatMessage>, int)? _recursiveSearch(
        List<ChatMessage> list, Set<int> visited) {
      if (!visited.add(identityHashCode(list))) return null;

      for (int i = 0; i < list.length; i++) {
        final msg = list[i];
        if (msg.id == messageId) {
          return (list, i);
        }
        if (msg.role == 'user' && session.branches.containsKey(msg.id)) {
          for (var branch in session.branches[msg.id]!) {
            final result = _recursiveSearch(branch, visited);
            if (result != null) {
              return result;
            }
          }
        }
      }
      return null;
    }

    return _recursiveSearch(session.messages, {});
  }

  Future<void> resubmitMessage(String messageId, String newContent,
      APIProvider provider, Model model, AppLocalizations localizations) async {
    if (_currentSession == null || isGenerating) return;

    final session = _currentSession!;
    final findResult = _findMessageAndParentListInSession(session, messageId);

    if (findResult == null) {
      debugPrint("NamelessAI - Could not find message to resubmit: $messageId");
      return;
    }

    final parentList = findResult.$1;
    final userMessageIndex = findResult.$2;
    final userMessageToEdit = parentList[userMessageIndex];

    parentList[userMessageIndex] =
        userMessageToEdit.copyWith(content: newContent, modelName: model.name);

    final ChatMessage newAssistantMessage;
    if (model.modelType != ModelType.language &&
        model.modelType != ModelType.image &&
        model.modelType != ModelType.video) {
      newAssistantMessage = ChatMessage(
        role: 'assistant',
        content: localizations.unsupportedModelTypeInChat,
        isLoading: false,
        isError: true,
        modelName: model.name,
      );
    } else {
      MessageType messageType;
      switch (model.modelType) {
        case ModelType.image:
          messageType = MessageType.image;
          break;
        case ModelType.video:
          messageType = MessageType.video;
          break;
        default:
          messageType = MessageType.text;
      }
      newAssistantMessage = ChatMessage(
        role: 'assistant',
        content: '',
        isLoading: true,
        modelName: model.name,
        messageType: messageType,
      );
    }

    final newBranch = [newAssistantMessage];
    final branchKey = userMessageToEdit.id;

    if (session.branches.containsKey(branchKey)) {
      session.branches[branchKey]!.add(newBranch);
      session.activeBranchSelections[branchKey] =
          session.branches[branchKey]!.length - 1;
    } else {
      if (userMessageIndex + 1 < parentList.length &&
          parentList[userMessageIndex + 1].role == 'assistant') {
        final originalBranch = parentList.sublist(userMessageIndex + 1);
        parentList.removeRange(userMessageIndex + 1, parentList.length);

        session.branches[branchKey] = [originalBranch, newBranch];
        session.activeBranchSelections[branchKey] = 1;
      } else {
        if (userMessageIndex + 1 < parentList.length) {
          parentList.removeRange(userMessageIndex + 1, parentList.length);
        }
        session.branches[branchKey] = [newBranch];
        session.activeBranchSelections[branchKey] = 0;
      }
    }

    if (model.modelType != ModelType.language &&
        model.modelType != ModelType.image &&
        model.modelType != ModelType.video) {
      await updateCurrentSession(session);
      return;
    }

    _generatingSessions.add(session.id);
    await updateCurrentSession(session);
    _performGeneration(
        session.id, newAssistantMessage.id, provider, model, localizations);
  }

  Future<void> regenerateResponse(String aiMessageId, APIProvider provider,
      Model model, AppLocalizations localizations) async {
    if (_currentSession == null || isGenerating) return;

    final session = _currentSession!;
    String? userMessageId;

    for (final entry in session.branches.entries) {
      for (final branch in entry.value) {
        if (branch.any((msg) => msg.id == aiMessageId)) {
          userMessageId = entry.key;
          break;
        }
      }
      if (userMessageId != null) break;
    }

    if (userMessageId == null) {
      final findResult =
          _findMessageAndParentListInSession(session, aiMessageId);
      if (findResult != null) {
        final (parentList, aiMessageIndex) = findResult;
        if (aiMessageIndex > 0 &&
            parentList[aiMessageIndex - 1].role == 'user') {
          userMessageId = parentList[aiMessageIndex - 1].id;
        }
      }
    }

    if (userMessageId == null) {
      debugPrint(
          "NamelessAI - Could not find parent user message for regen: $aiMessageId");
      return;
    }

    final userMessage = _findMessageInSession(session, userMessageId);
    if (userMessage == null) {
      debugPrint(
          "NamelessAI - Could not find user message object for regen: $userMessageId");
      return;
    }

    await resubmitMessage(
        userMessage.id, userMessage.content, provider, model, localizations);
  }

  Future<void> switchActiveBranch(String userMessageId, int branchIndex) async {
    if (_currentSession == null) return;
    final session = _currentSession!;
    if (session.branches.containsKey(userMessageId) &&
        branchIndex < session.branches[userMessageId]!.length) {
      session.activeBranchSelections[userMessageId] = branchIndex;
      await updateCurrentSession(session);
    }
  }

  void cancelGeneration(String sessionId) {
    if (_generatingSessions.contains(sessionId)) {
      _cancelTokens[sessionId]?.cancel("Operation cancelled by user.");
      NotificationService().cancelThinkingNotification();
      debugPrint("NamelessAI - Cancellation requested for session $sessionId");
    }
  }

  Future<void> _performGeneration(String sessionId, String assistantMessageId,
      APIProvider provider, Model model, AppLocalizations localizations) async {
    final session = AppDatabase.chatSessionsBox.get(sessionId);
    if (session == null) {
      _generatingSessions.remove(sessionId);
      notifyListeners();
      return;
    }

    if (_currentSession?.id == sessionId) {
      _currentSession = session;
    }

    final cancelToken = CancelToken();
    _cancelTokens[sessionId] = cancelToken;

    var messagesForApi = session.activeMessages
        .where((m) => m.id != assistantMessageId)
        .toList();

    if (session.maxContextMessages != null && session.maxContextMessages! > 0) {
      if (messagesForApi.length > session.maxContextMessages!) {
        messagesForApi = messagesForApi
            .sublist(messagesForApi.length - session.maxContextMessages!);
      }
    }

    final messageToUpdate = _findMessageInSession(session, assistantMessageId);
    if (messageToUpdate == null) {
      _generatingSessions.remove(sessionId);
      notifyListeners();
      return;
    }

    final appConfigProvider = AppConfigProvider();

    final generationService = GenerationService(
      provider: provider,
      model: model,
      session: session,
      assistantMessageId: assistantMessageId,
      messagesForApi: messagesForApi,
      cancelToken: cancelToken,
      messageToUpdate: messageToUpdate,
      onUpdate: () {
        notifyListeners();
      },
      localizations: localizations,
      appConfig: appConfigProvider,
      notificationService: NotificationService(),
    );

    await generationService.execute();

    if (messageToUpdate.content == localizations.cancelled) {
      _removeMessageInSession(session, assistantMessageId);
    }

    session.updatedAt = DateTime.now();
    await session.save();

    _generatingSessions.remove(sessionId);
    _cancelTokens.remove(sessionId);
    _loadSessions();
    if (_currentSession?.id == session.id) {
      _currentSession = session;
    }
    notifyListeners();
  }

  Future<void> refreshAsyncTaskStatus(
      String messageId, APIProvider provider, Model model) async {
    if (_currentSession == null) return;
    final session = _currentSession!;
    final message = _findMessageInSession(session, messageId);

    if (message == null || message.taskId == null) {
      return;
    }

    message.isLoading = true;
    notifyListeners();

    try {
      if (model.modelType == ModelType.video) {
        await _refreshVideoTask(message, provider, model);
      } else if (model.compatibilityMode == CompatibilityMode.midjourneyProxy) {
        await _refreshMidjourneyTask(message, provider, model);
      }
    } catch (e) {
      message.isError = true;
      message.content = e.toString();
      message.asyncTaskStatus = AsyncTaskStatus.failure;
    } finally {
      message.isLoading = false;
      await updateCurrentSession(session);
    }
  }

  Future<void> _refreshMidjourneyTask(
      ChatMessage message, APIProvider provider, Model model) async {
    final apiService = ApiService(provider);
    final response =
        await apiService.fetchMidjourneyTask(message.taskId!, model);
    message.rawResponseJson = response.rawResponse;
    message.asyncTaskFullResponse = jsonEncode(response.toJson());
    final interval = AppDatabase.appConfigBox
        .get('asyncTaskRefreshInterval', defaultValue: 10) as int;

    if (response.status == 'SUCCESS') {
      message.asyncTaskStatus = AsyncTaskStatus.success;
      message.content = response.imageUrl ?? message.content;
      message.asyncTaskProgress = '100%';
      message.nextRefreshTime = null;
    } else if (response.status == 'FAILURE') {
      message.asyncTaskStatus = AsyncTaskStatus.failure;
      message.isError = true;
      message.content = response.failReason ?? 'Task failed without reason.';
      message.nextRefreshTime = null;
    } else if (response.status == 'IN_PROGRESS') {
      message.asyncTaskStatus = AsyncTaskStatus.inProgress;
      message.asyncTaskProgress = response.progress;
      if (interval > 0) {
        message.nextRefreshTime =
            DateTime.now().add(Duration(seconds: interval));
      }
    } else {
      message.asyncTaskStatus = AsyncTaskStatus.submitted;
      message.asyncTaskProgress = response.progress;
      if (interval > 0) {
        message.nextRefreshTime =
            DateTime.now().add(Duration(seconds: interval));
      }
    }
  }

  Future<void> _refreshVideoTask(
      ChatMessage message, APIProvider provider, Model model) async {
    final apiService = ApiService(provider);
    final response = await apiService.queryVideoTask(message.taskId!, model);
    message.rawResponseJson = response.rawResponse;
    message.asyncTaskFullResponse = jsonEncode(response.toJson());
    final interval = AppDatabase.appConfigBox
        .get('asyncTaskRefreshInterval', defaultValue: 10) as int;

    final status = response.status.toUpperCase();
    if (status == 'SUCCESS' || status == 'COMPLETED') {
      message.asyncTaskStatus = AsyncTaskStatus.success;
      message.videoUrl = response.videoUrl;
      message.content = 'Video generated successfully.';
      message.asyncTaskProgress = '100%';
      message.nextRefreshTime = null;
    } else if (status == 'FAILURE' || status == 'FAILED') {
      message.asyncTaskStatus = AsyncTaskStatus.failure;
      message.isError = true;
      message.content = 'Video generation failed.';
      message.nextRefreshTime = null;
    } else if (status == 'IN_PROGRESS' || status == 'PROCESSING') {
      message.asyncTaskStatus = AsyncTaskStatus.inProgress;
      message.content = 'Video generation in progress...';
      if (interval > 0) {
        message.nextRefreshTime =
            DateTime.now().add(Duration(seconds: interval));
      }
    } else {
      message.asyncTaskStatus = AsyncTaskStatus.submitted;
      message.content = 'Video task submitted: ${response.status}';
      if (interval > 0) {
        message.nextRefreshTime =
            DateTime.now().add(Duration(seconds: interval));
      }
    }
  }

  void _addMessageToActivePath(ChatSession session, ChatMessage message) {
    if (session.messages.isEmpty) {
      session.messages.add(message);
      return;
    }
    List<ChatMessage> findListToAppend(List<ChatMessage> currentList) {
      if (currentList.isEmpty) return currentList;
      final lastMsg = currentList.last;
      if (lastMsg.role == 'user' && session.branches.containsKey(lastMsg.id)) {
        final branchKey = lastMsg.id;
        final activeIndex = session.activeBranchSelections[branchKey] ?? 0;
        return findListToAppend(session.branches[branchKey]![activeIndex]);
      }
      return currentList;
    }

    final targetList = findListToAppend(session.messages);
    targetList.add(message);
  }

  ChatMessage? _findMessageInSession(ChatSession session, String id) {
    ChatMessage? _recursiveFind(List<ChatMessage> list, Set<int> visited) {
      if (!visited.add(identityHashCode(list))) return null;
      for (var msg in list) {
        if (msg.id == id) return msg;
        if (msg.role == 'user' && session.branches.containsKey(msg.id)) {
          for (var branch in session.branches[msg.id]!) {
            final found = _recursiveFind(branch, visited);
            if (found != null) return found;
          }
        }
      }
      return null;
    }

    return _recursiveFind(session.messages, {});
  }

  bool _removeMessageInSession(ChatSession session, String id) {
    bool _recursiveRemove(List<ChatMessage> list, Set<int> visited) {
      if (!visited.add(identityHashCode(list))) return false;
      final initialLength = list.length;
      list.removeWhere((msg) => msg.id == id);
      if (list.length < initialLength) return true;
      for (var msg in list) {
        if (msg.role == 'user' && session.branches.containsKey(msg.id)) {
          for (var branch in session.branches[msg.id]!) {
            if (_recursiveRemove(branch, visited)) return true;
          }
        }
      }
      return false;
    }

    return _recursiveRemove(session.messages, {});
  }
}
