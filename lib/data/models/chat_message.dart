import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat_message.g.dart';

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
    );
  }
}
