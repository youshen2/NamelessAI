import 'package:flutter/material.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/providers/chat_session_manager.dart';

class StatisticsProvider extends ChangeNotifier {
  ChatSessionManager _chatManager;

  int _totalChats = 0;
  int _totalMessages = 0;
  int _userMessages = 0;
  int _aiMessages = 0;
  int _totalPromptTokens = 0;
  int _totalCompletionTokens = 0;
  double _averageResponseTime = 0.0;
  Map<String, int> _modelUsage = {};
  Map<DateTime, int> _chatsLast7Days = {};

  StatisticsProvider(this._chatManager) {
    _chatManager.addListener(recalculate);
    recalculate();
  }

  @override
  void dispose() {
    _chatManager.removeListener(recalculate);
    super.dispose();
  }

  void update(ChatSessionManager newManager) {
    if (_chatManager != newManager) {
      _chatManager.removeListener(recalculate);
      _chatManager = newManager;
      _chatManager.addListener(recalculate);
      recalculate();
    }
  }

  int get totalChats => _totalChats;
  int get totalMessages => _totalMessages;
  int get userMessages => _userMessages;
  int get aiMessages => _aiMessages;
  int get totalPromptTokens => _totalPromptTokens;
  int get totalCompletionTokens => _totalCompletionTokens;
  double get averageResponseTime => _averageResponseTime;
  Map<String, int> get modelUsage => _modelUsage;
  Map<DateTime, int> get chatsLast7Days => _chatsLast7Days;

  List<ChatMessage> _getAllMessages(ChatSession session) {
    final allMessages = <ChatMessage>[];
    final visitedLists = <int>{};

    void recursiveCollector(List<ChatMessage> messages) {
      if (!visitedLists.add(identityHashCode(messages))) return;

      for (final msg in messages) {
        allMessages.add(msg);
        if (msg.role == 'user' && session.branches.containsKey(msg.id)) {
          for (final branch in session.branches[msg.id]!) {
            recursiveCollector(branch);
          }
        }
      }
    }

    recursiveCollector(session.messages);
    return allMessages;
  }

  void recalculate() {
    final sessions = _chatManager.sessions;

    _totalChats = sessions.length;
    _userMessages = 0;
    _aiMessages = 0;
    _totalPromptTokens = 0;
    _totalCompletionTokens = 0;
    _modelUsage = {};
    _chatsLast7Days = {};

    int totalCompletionTimeMs = 0;
    int completionCount = 0;

    for (final session in sessions) {
      final allMessagesInSession = _getAllMessages(session);
      for (final message in allMessagesInSession) {
        if (message.role == 'user') {
          _userMessages++;
        } else if (message.role == 'assistant') {
          _aiMessages++;
          if (message.modelName != null && message.modelName!.isNotEmpty) {
            _modelUsage[message.modelName!] =
                (_modelUsage[message.modelName!] ?? 0) + 1;
          }
          if (message.promptTokens != null) {
            _totalPromptTokens += message.promptTokens!;
          }
          if (message.completionTokens != null) {
            _totalCompletionTokens += message.completionTokens!;
          }
          if (message.completionTimeMs != null) {
            totalCompletionTimeMs += message.completionTimeMs!;
            completionCount++;
          }
        }
      }
    }

    _totalMessages = _userMessages + _aiMessages;
    _averageResponseTime =
        completionCount > 0 ? (totalCompletionTimeMs / completionCount) : 0.0;

    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final dateOnlySevenDaysAgo =
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

    for (int i = 0; i < 7; i++) {
      final date = dateOnlySevenDaysAgo.add(Duration(days: i));
      _chatsLast7Days[date] = 0;
    }

    for (final session in sessions) {
      final sessionDate = DateTime(session.createdAt.year,
          session.createdAt.month, session.createdAt.day);
      if (!sessionDate.isBefore(dateOnlySevenDaysAgo)) {
        if (_chatsLast7Days.containsKey(sessionDate)) {
          _chatsLast7Days[sessionDate] = _chatsLast7Days[sessionDate]! + 1;
        }
      }
    }

    notifyListeners();
  }
}
