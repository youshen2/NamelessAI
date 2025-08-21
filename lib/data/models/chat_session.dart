import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:nameless_ai/data/models/chat_message.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 3)
class ChatSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? providerId;

  @HiveField(3)
  String? modelId;

  @HiveField(4)
  List<ChatMessage> messages;

  @HiveField(5)
  String? systemPrompt;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  double temperature;

  @HiveField(9)
  double topP;

  @HiveField(10)
  Map<String, List<List<ChatMessage>>> branches;

  @HiveField(11)
  Map<String, int> activeBranchSelections;

  @HiveField(12)
  bool? useStreaming;

  ChatSession({
    String? id,
    required this.name,
    this.providerId,
    this.modelId,
    List<ChatMessage>? messages,
    this.systemPrompt,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? temperature,
    double? topP,
    Map<String, List<List<ChatMessage>>>? branches,
    Map<String, int>? activeBranchSelections,
    this.useStreaming,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        temperature = temperature ?? 0.7,
        topP = topP ?? 1.0,
        branches = branches ?? {},
        activeBranchSelections = activeBranchSelections ?? {};

  ChatSession copyWith({
    String? id,
    String? name,
    String? providerId,
    String? modelId,
    List<ChatMessage>? messages,
    String? systemPrompt,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? temperature,
    double? topP,
    Map<String, List<List<ChatMessage>>>? branches,
    Map<String, int>? activeBranchSelections,
    bool? useStreaming,
  }) {
    return ChatSession(
      id: id ?? this.id,
      name: name ?? this.name,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      messages: messages ?? this.messages,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      branches: branches ?? this.branches,
      activeBranchSelections:
          activeBranchSelections ?? this.activeBranchSelections,
      useStreaming: useStreaming ?? this.useStreaming,
    );
  }
}

extension ChatSessionExtensions on ChatSession {
  List<ChatMessage> get activeMessages {
    final List<ChatMessage> activeList = [];
    _buildActiveMessageList(messages, activeList, {});
    return activeList;
  }

  void _buildActiveMessageList(
      List<ChatMessage> source, List<ChatMessage> target, Set<int> visited) {
    if (source.isEmpty || !visited.add(identityHashCode(source))) return;

    for (var message in source) {
      target.add(message);
      if (message.role == 'user' && branches.containsKey(message.id)) {
        final messageBranches = branches[message.id]!;
        final activeBranchIndex = activeBranchSelections[message.id] ?? 0;
        if (activeBranchIndex < messageBranches.length) {
          _buildActiveMessageList(
              messageBranches[activeBranchIndex], target, visited);
        }
      }
    }
  }
}
