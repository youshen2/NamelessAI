import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'api_provider.g.dart';

@HiveType(typeId: 0)
class APIProvider extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String baseUrl;

  @HiveField(3)
  String apiKey;

  @HiveField(4)
  List<Model> models;

  @HiveField(5)
  String chatCompletionPath;

  APIProvider({
    String? id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    List<Model>? models,
    String? chatCompletionPath,
  })  : id = id ?? const Uuid().v4(),
        models = models ?? [],
        chatCompletionPath = chatCompletionPath ?? '/v1/chat/completions';

  APIProvider copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    List<Model>? models,
    String? chatCompletionPath,
  }) {
    return APIProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      models: models ?? this.models,
      chatCompletionPath: chatCompletionPath ?? this.chatCompletionPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'models': models.map((m) => m.toJson()).toList(),
        'chatCompletionPath': chatCompletionPath,
      };

  factory APIProvider.fromJson(Map<String, dynamic> json) => APIProvider(
        id: json['id'],
        name: json['name'],
        baseUrl: json['baseUrl'],
        apiKey: json['apiKey'],
        models: (json['models'] as List).map((m) => Model.fromJson(m)).toList(),
        chatCompletionPath: json['chatCompletionPath'],
      );
}

@HiveType(typeId: 1)
class Model extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? maxTokens;

  @HiveField(3)
  bool isStreamable;

  @HiveField(4, defaultValue: false)
  bool supportsThinking;

  Model({
    String? id,
    required this.name,
    this.maxTokens,
    required this.isStreamable,
    this.supportsThinking = false,
  }) : id = id ?? const Uuid().v4();

  Model copyWith({
    String? id,
    String? name,
    int? maxTokens,
    bool? isStreamable,
    bool? supportsThinking,
  }) {
    return Model(
      id: id ?? this.id,
      name: name ?? this.name,
      maxTokens: maxTokens ?? this.maxTokens,
      isStreamable: isStreamable ?? this.isStreamable,
      supportsThinking: supportsThinking ?? this.supportsThinking,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'maxTokens': maxTokens,
        'isStreamable': isStreamable,
        'supportsThinking': supportsThinking,
      };

  factory Model.fromJson(Map<String, dynamic> json) => Model(
        id: json['id'],
        name: json['name'],
        maxTokens: json['maxTokens'],
        isStreamable: json['isStreamable'],
        supportsThinking: json['supportsThinking'] ?? false,
      );
}
