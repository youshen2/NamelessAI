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

  Model({
    String? id,
    required this.name,
    this.maxTokens,
    required this.isStreamable,
  }) : id = id ?? const Uuid().v4();

  Model copyWith({
    String? id,
    String? name,
    int? maxTokens,
    bool? isStreamable,
  }) {
    return Model(
      id: id ?? this.id,
      name: name ?? this.name,
      maxTokens: maxTokens ?? this.maxTokens,
      isStreamable: isStreamable ?? this.isStreamable,
    );
  }
}
