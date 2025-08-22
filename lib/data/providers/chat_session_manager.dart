import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/models.dart' as api_models;
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/services/chat_service.dart';

class ChatSessionManager extends ChangeNotifier {
  static const String _defaultSystemPrompt = "You are a helpful assistant.";
  static const double _defaultTemperature = 0.7;
  static const double _defaultTopP = 1.0;

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isNewSession = true;
  final Set<String> _generatingSessions = {};

  ChatSessionManager() {
    _loadSessions();
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

  void _loadSessions() {
    _sessions = AppDatabase.chatSessionsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
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
    );
    _isNewSession = true;
    notifyListeners();
  }

  void loadSession(String sessionId) {
    final session = AppDatabase.chatSessionsBox.get(sessionId);
    if (session != null) {
      _currentSession = session;
      _isNewSession = false;
      notifyListeners();
    }
  }

  void _clearAllEditingStates(ChatSession session) {
    void recursiveClear(List<ChatMessage> messages, Set<int> visited) {
      if (messages.isEmpty || !visited.add(identityHashCode(messages))) return;
      for (var msg in messages) {
        msg.isEditing = false;
        if (msg.role == 'assistant' && session.branches.containsKey(msg.id)) {
          for (var branch in session.branches[msg.id]!) {
            recursiveClear(branch, visited);
          }
        }
      }
    }

    recursiveClear(session.messages, {});
  }

  Future<void> saveCurrentSession(String name) async {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );

    _clearAllEditingStates(_currentSession!);

    await AppDatabase.chatSessionsBox
        .put(_currentSession!.id, _currentSession!);
    _loadSessions();
    _isNewSession = false;
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
      _clearAllEditingStates(_currentSession!);
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
  }) async {
    if (_currentSession == null) return;

    final sessionToUpdate = _currentSession!;
    var updatedSession = sessionToUpdate.copyWith(
      providerId: providerId,
      modelId: modelId,
      systemPrompt: systemPrompt,
      temperature: temperature,
      topP: topP,
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

  void toggleMessageEditing(String messageId, bool isEditing) {
    if (_currentSession == null) return;
    final message = _findMessageInSession(_currentSession!, messageId);
    if (message != null) {
      message.isEditing = isEditing;
      notifyListeners();
    }
  }

  void updateMessageInCurrentSession(String messageId, String newContent) {
    if (_currentSession == null) return;
    final message = _findMessageInSession(_currentSession!, messageId);
    if (message != null) {
      message.content = newContent;
      message.isEditing = false;
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

  Future<void> sendMessage(
      String text, APIProvider provider, Model model) async {
    if (isGenerating) return;

    if (_currentSession == null) {
      startNewSession(providerId: provider.id, modelId: model.id);
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

    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: '',
      isLoading: true,
      modelName: model.name,
    );
    _addMessageToActivePath(_currentSession!, assistantMessage);

    _generatingSessions.add(sessionId);
    notifyListeners();

    _performGeneration(sessionId, assistantMessage.id, provider, model);
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
      APIProvider provider, Model model) async {
    if (_currentSession == null || isGenerating) return;

    final session = _currentSession!;
    final findResult = _findMessageAndParentListInSession(session, messageId);

    if (findResult == null) {
      debugPrint("NamelessAI - Could not find message to resubmit: $messageId");
      return;
    }

    final (parentList, userMessageIndex) = findResult;
    final userMessageToEdit = parentList[userMessageIndex];

    userMessageToEdit.content = newContent;
    userMessageToEdit.isEditing = false;
    userMessageToEdit.modelName = model.name;

    final newAssistantMessage = ChatMessage(
      role: 'assistant',
      content: '',
      isLoading: true,
      modelName: model.name,
    );
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

    _generatingSessions.add(session.id);
    await updateCurrentSession(session);
    _performGeneration(session.id, newAssistantMessage.id, provider, model);
  }

  Future<void> regenerateResponse(
      String aiMessageId, APIProvider provider, Model model) async {
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

    await resubmitMessage(userMessage.id, userMessage.content, provider, model);
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

  Future<void> _performGeneration(String sessionId, String assistantMessageId,
      APIProvider provider, Model model) async {
    final session = AppDatabase.chatSessionsBox.get(sessionId);
    if (session == null) {
      _generatingSessions.remove(sessionId);
      notifyListeners();
      return;
    }

    final chatService = ChatService(provider: provider, model: model);

    var messagesForApi = session.activeMessages
        .where((m) => m.id != assistantMessageId)
        .toList();

    if (session.maxContextMessages != null && session.maxContextMessages! > 0) {
      if (messagesForApi.length > session.maxContextMessages!) {
        messagesForApi = messagesForApi
            .sublist(messagesForApi.length - session.maxContextMessages!);
      }
    }

    final stopwatch = Stopwatch()..start();
    int? firstChunkTimeMs;
    String fullResponseBuffer = '';
    api_models.Usage? usage;
    const thinkTag = '</think>';
    bool thinkingDone = false;

    try {
      final useStreaming = session.useStreaming ?? model.isStreamable;
      final messageToUpdate =
          _findMessageInSession(session, assistantMessageId);
      if (messageToUpdate == null) return;

      if (useStreaming) {
        final stream = chatService.getCompletionStream(
          messagesForApi,
          session.systemPrompt,
          session.temperature,
          session.topP,
        );

        await for (final item in stream) {
          if (item is String) {
            if (firstChunkTimeMs == null) {
              firstChunkTimeMs = stopwatch.elapsedMilliseconds;
              messageToUpdate.thinkingStartTime = DateTime.now();
            }
            fullResponseBuffer += item;

            if (!thinkingDone && fullResponseBuffer.contains(thinkTag)) {
              thinkingDone = true;
              final parts = fullResponseBuffer.split(thinkTag);
              messageToUpdate.thinkingContent = parts[0];
              messageToUpdate.content = parts.length > 1 ? parts[1] : '';
              messageToUpdate.thinkingDurationMs = DateTime.now()
                  .difference(messageToUpdate.thinkingStartTime!)
                  .inMilliseconds;
            } else if (!thinkingDone) {
              messageToUpdate.thinkingContent = fullResponseBuffer;
            } else {
              messageToUpdate.content = (messageToUpdate.content ?? '') + item;
            }
            await session.save();
            notifyListeners();
          } else if (item is api_models.Usage) {
            usage = item;
          }
        }
      } else {
        final response = await chatService.getCompletion(
          messagesForApi,
          session.systemPrompt,
          session.temperature,
          session.topP,
        );
        fullResponseBuffer = response.choices.first.message.content;
        usage = response.usage;

        if (fullResponseBuffer.contains(thinkTag)) {
          final parts = fullResponseBuffer.split(thinkTag);
          messageToUpdate.thinkingContent = parts[0];
          messageToUpdate.content = parts.length > 1 ? parts[1] : '';
        } else {
          messageToUpdate.content = fullResponseBuffer;
        }
      }
    } catch (e) {
      final messageToUpdate =
          _findMessageInSession(session, assistantMessageId);
      if (messageToUpdate != null) {
        messageToUpdate.content = "Error: ${e.toString()}";
        messageToUpdate.isError = true;
      }
    } finally {
      stopwatch.stop();
      final finalMessage = _findMessageInSession(session, assistantMessageId);
      if (finalMessage != null) {
        finalMessage.isLoading = false;
        finalMessage.completionTimeMs = stopwatch.elapsedMilliseconds;
        finalMessage.firstChunkTimeMs = firstChunkTimeMs;
        finalMessage.outputCharacters = (finalMessage.content ?? '').length;
        if (usage != null) {
          finalMessage.promptTokens = usage.promptTokens;
          finalMessage.completionTokens = usage.completionTokens;
        }
        finalMessage.thinkingStartTime = null;
      }

      session.updatedAt = DateTime.now();
      await session.save();
      notifyListeners();

      _generatingSessions.remove(sessionId);
      _loadSessions();
      if (_currentSession?.id == session.id) {
        _currentSession = session;
      }
      notifyListeners();
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
