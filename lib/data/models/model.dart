import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:nameless_ai/data/models/model_type.dart';

part 'model.g.dart';

@HiveType(typeId: 16)
enum ImageGenerationMode {
  @HiveField(0)
  instant,
  @HiveField(1)
  asynchronous,
}

@HiveType(typeId: 17)
enum CompatibilityMode {
  @HiveField(0)
  midjourneyProxy,
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

  @HiveField(4, defaultValue: ModelType.language)
  ModelType modelType;

  @HiveField(5, defaultValue: ImageGenerationMode.instant)
  ImageGenerationMode imageGenerationMode;

  @HiveField(6)
  CompatibilityMode? compatibilityMode;

  @HiveField(7)
  String? imaginePath;

  @HiveField(8)
  String? fetchPath;

  @HiveField(9)
  String? chatPath;

  Model({
    String? id,
    required this.name,
    this.maxTokens,
    required this.isStreamable,
    this.modelType = ModelType.language,
    this.imageGenerationMode = ImageGenerationMode.instant,
    this.compatibilityMode,
    this.imaginePath,
    this.fetchPath,
    this.chatPath,
  }) : id = id ?? const Uuid().v4();

  Model copyWith({
    String? id,
    String? name,
    int? maxTokens,
    bool? isStreamable,
    ModelType? modelType,
    ImageGenerationMode? imageGenerationMode,
    CompatibilityMode? compatibilityMode,
    String? imaginePath,
    String? fetchPath,
    String? chatPath,
  }) {
    return Model(
      id: id ?? this.id,
      name: name ?? this.name,
      maxTokens: maxTokens ?? this.maxTokens,
      isStreamable: isStreamable ?? this.isStreamable,
      modelType: modelType ?? this.modelType,
      imageGenerationMode: imageGenerationMode ?? this.imageGenerationMode,
      compatibilityMode: compatibilityMode ?? this.compatibilityMode,
      imaginePath: imaginePath ?? this.imaginePath,
      fetchPath: fetchPath ?? this.fetchPath,
      chatPath: chatPath ?? this.chatPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'maxTokens': maxTokens,
        'isStreamable': isStreamable,
        'modelType': modelType.name,
        'imageGenerationMode': imageGenerationMode.name,
        'compatibilityMode': compatibilityMode?.name,
        'imaginePath': imaginePath,
        'fetchPath': fetchPath,
        'chatPath': chatPath,
      };

  factory Model.fromJson(Map<String, dynamic> json) => Model(
        id: json['id'],
        name: json['name'],
        maxTokens: json['maxTokens'],
        isStreamable: json['isStreamable'],
        modelType: ModelType.values.firstWhere(
            (e) => e.name == json['modelType'],
            orElse: () => ModelType.language),
        imageGenerationMode: ImageGenerationMode.values.firstWhere(
            (e) => e.name == json['imageGenerationMode'],
            orElse: () => ImageGenerationMode.instant),
        compatibilityMode: json['compatibilityMode'] == null
            ? null
            : CompatibilityMode.values.firstWhere(
                (e) => e.name == json['compatibilityMode'],
                orElse: () => CompatibilityMode.midjourneyProxy),
        imaginePath: json['imaginePath'],
        fetchPath: json['fetchPath'],
        chatPath: json['chatPath'],
      );
}
