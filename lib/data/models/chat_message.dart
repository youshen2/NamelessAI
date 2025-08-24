import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 15)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  video,
}

@HiveType(typeId: 18)
enum AsyncTaskStatus {
  @HiveField(0)
  none,
  @HiveField(1)
  submitted,
  @HiveField(2)
  inProgress,
  @HiveField(3)
  failure,
  @HiveField(4)
  success,
}

@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String role;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4, defaultValue: false)
  bool isEditing;

  @HiveField(5, defaultValue: false)
  bool isLoading;

  @HiveField(6)
  int? promptTokens;

  @HiveField(7)
  int? completionTokens;

  @HiveField(8)
  int? completionTimeMs;

  @HiveField(9)
  int? firstChunkTimeMs;

  @HiveField(10)
  int? outputCharacters;

  @HiveField(11, defaultValue: false)
  bool isError;

  @HiveField(12)
  String? modelName;

  @HiveField(13)
  String? thinkingContent;

  @HiveField(14)
  int? thinkingDurationMs;

  @HiveField(15, defaultValue: MessageType.text)
  MessageType messageType;

  @HiveField(16)
  String? taskId;

  @HiveField(17, defaultValue: AsyncTaskStatus.none)
  AsyncTaskStatus asyncTaskStatus;

  @HiveField(18)
  String? asyncTaskProgress;

  @HiveField(19)
  String? asyncTaskFullResponse;

  @HiveField(20)
  String? rawResponseJson;

  @HiveField(21)
  String? enhancedPrompt;

  @HiveField(22)
  String? videoUrl;

  DateTime? thinkingStartTime;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isEditing = false,
    this.isLoading = false,
    this.promptTokens,
    this.completionTokens,
    this.completionTimeMs,
    this.firstChunkTimeMs,
    this.outputCharacters,
    this.isError = false,
    this.modelName,
    this.thinkingContent,
    this.thinkingDurationMs,
    this.thinkingStartTime,
    this.messageType = MessageType.text,
    this.taskId,
    this.asyncTaskStatus = AsyncTaskStatus.none,
    this.asyncTaskProgress,
    this.asyncTaskFullResponse,
    this.rawResponseJson,
    this.enhancedPrompt,
    this.videoUrl,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isEditing,
    bool? isLoading,
    int? promptTokens,
    int? completionTokens,
    int? completionTimeMs,
    int? firstChunkTimeMs,
    int? outputCharacters,
    bool? isError,
    String? modelName,
    String? thinkingContent,
    int? thinkingDurationMs,
    DateTime? thinkingStartTime,
    MessageType? messageType,
    String? taskId,
    AsyncTaskStatus? asyncTaskStatus,
    String? asyncTaskProgress,
    String? asyncTaskFullResponse,
    String? rawResponseJson,
    String? enhancedPrompt,
    String? videoUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isEditing: isEditing ?? this.isEditing,
      isLoading: isLoading ?? this.isLoading,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      completionTimeMs: completionTimeMs ?? this.completionTimeMs,
      firstChunkTimeMs: firstChunkTimeMs ?? this.firstChunkTimeMs,
      outputCharacters: outputCharacters ?? this.outputCharacters,
      isError: isError ?? this.isError,
      modelName: modelName ?? this.modelName,
      thinkingContent: thinkingContent ?? this.thinkingContent,
      thinkingDurationMs: thinkingDurationMs ?? this.thinkingDurationMs,
      thinkingStartTime: thinkingStartTime ?? this.thinkingStartTime,
      messageType: messageType ?? this.messageType,
      taskId: taskId ?? this.taskId,
      asyncTaskStatus: asyncTaskStatus ?? this.asyncTaskStatus,
      asyncTaskProgress: asyncTaskProgress ?? this.asyncTaskProgress,
      asyncTaskFullResponse:
          asyncTaskFullResponse ?? this.asyncTaskFullResponse,
      rawResponseJson: rawResponseJson ?? this.rawResponseJson,
      enhancedPrompt: enhancedPrompt ?? this.enhancedPrompt,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isEditing': isEditing,
        'isLoading': isLoading,
        'promptTokens': promptTokens,
        'completionTokens': completionTokens,
        'completionTimeMs': completionTimeMs,
        'firstChunkTimeMs': firstChunkTimeMs,
        'outputCharacters': outputCharacters,
        'isError': isError,
        'modelName': modelName,
        'thinkingContent': thinkingContent,
        'thinkingDurationMs': thinkingDurationMs,
        'messageType': messageType.name,
        'taskId': taskId,
        'asyncTaskStatus': asyncTaskStatus.name,
        'asyncTaskProgress': asyncTaskProgress,
        'asyncTaskFullResponse': asyncTaskFullResponse,
        'rawResponseJson': rawResponseJson,
        'enhancedPrompt': enhancedPrompt,
        'videoUrl': videoUrl,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        role: json['role'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        isEditing: json['isEditing'] ?? false,
        isLoading: json['isLoading'] ?? false,
        promptTokens: json['promptTokens'],
        completionTokens: json['completionTokens'],
        completionTimeMs: json['completionTimeMs'],
        firstChunkTimeMs: json['firstChunkTimeMs'],
        outputCharacters: json['outputCharacters'],
        isError: json['isError'] ?? false,
        modelName: json['modelName'],
        thinkingContent: json['thinkingContent'],
        thinkingDurationMs: json['thinkingDurationMs'],
        messageType: MessageType.values.firstWhere(
            (e) => e.name == json['messageType'],
            orElse: () => MessageType.text),
        taskId: json['taskId'],
        asyncTaskStatus: AsyncTaskStatus.values.firstWhere(
            (e) => e.name == json['asyncTaskStatus'],
            orElse: () => AsyncTaskStatus.none),
        asyncTaskProgress: json['asyncTaskProgress'],
        asyncTaskFullResponse: json['asyncTaskFullResponse'],
        rawResponseJson: json['rawResponseJson'],
        enhancedPrompt: json['enhancedPrompt'],
        videoUrl: json['videoUrl'],
      );
}
