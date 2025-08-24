import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:nameless_ai/data/models/model_type.dart';

part 'model.g.dart';

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

  @HiveField(5, defaultValue: ModelType.language)
  ModelType modelType;

  Model({
    String? id,
    required this.name,
    this.maxTokens,
    required this.isStreamable,
    this.supportsThinking = false,
    this.modelType = ModelType.language,
  }) : id = id ?? const Uuid().v4();

  Model copyWith({
    String? id,
    String? name,
    int? maxTokens,
    bool? isStreamable,
    bool? supportsThinking,
    ModelType? modelType,
  }) {
    return Model(
      id: id ?? this.id,
      name: name ?? this.name,
      maxTokens: maxTokens ?? this.maxTokens,
      isStreamable: isStreamable ?? this.isStreamable,
      supportsThinking: supportsThinking ?? this.supportsThinking,
      modelType: modelType ?? this.modelType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'maxTokens': maxTokens,
        'isStreamable': isStreamable,
        'supportsThinking': supportsThinking,
        'modelType': modelType.name,
      };

  factory Model.fromJson(Map<String, dynamic> json) => Model(
        id: json['id'],
        name: json['name'],
        maxTokens: json['maxTokens'],
        isStreamable: json['isStreamable'],
        supportsThinking: json['supportsThinking'] ?? false,
        modelType: ModelType.values.firstWhere(
            (e) => e.name == json['modelType'],
            orElse: () => ModelType.language),
      );
}
