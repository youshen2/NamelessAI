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
enum AsyncImageType {
  @HiveField(0)
  midjourney,
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

  @HiveField(5, defaultValue: ModelType.language)
  ModelType modelType;

  @HiveField(6, defaultValue: ImageGenerationMode.instant)
  ImageGenerationMode imageGenerationMode;

  @HiveField(7)
  AsyncImageType? asyncImageType;

  @HiveField(8)
  String? imaginePath;

  @HiveField(9)
  String? fetchPath;

  Model({
    String? id,
    required this.name,
    this.maxTokens,
    required this.isStreamable,
    this.supportsThinking = false,
    this.modelType = ModelType.language,
    this.imageGenerationMode = ImageGenerationMode.instant,
    this.asyncImageType,
    this.imaginePath,
    this.fetchPath,
  }) : id = id ?? const Uuid().v4();

  Model copyWith({
    String? id,
    String? name,
    int? maxTokens,
    bool? isStreamable,
    bool? supportsThinking,
    ModelType? modelType,
    ImageGenerationMode? imageGenerationMode,
    AsyncImageType? asyncImageType,
    String? imaginePath,
    String? fetchPath,
  }) {
    return Model(
      id: id ?? this.id,
      name: name ?? this.name,
      maxTokens: maxTokens ?? this.maxTokens,
      isStreamable: isStreamable ?? this.isStreamable,
      supportsThinking: supportsThinking ?? this.supportsThinking,
      modelType: modelType ?? this.modelType,
      imageGenerationMode: imageGenerationMode ?? this.imageGenerationMode,
      asyncImageType: asyncImageType ?? this.asyncImageType,
      imaginePath: imaginePath ?? this.imaginePath,
      fetchPath: fetchPath ?? this.fetchPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'maxTokens': maxTokens,
        'isStreamable': isStreamable,
        'supportsThinking': supportsThinking,
        'modelType': modelType.name,
        'imageGenerationMode': imageGenerationMode.name,
        'asyncImageType': asyncImageType?.name,
        'imaginePath': imaginePath,
        'fetchPath': fetchPath,
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
        imageGenerationMode: ImageGenerationMode.values.firstWhere(
            (e) => e.name == json['imageGenerationMode'],
            orElse: () => ImageGenerationMode.instant),
        asyncImageType: json['asyncImageType'] == null
            ? null
            : AsyncImageType.values.firstWhere(
                (e) => e.name == json['asyncImageType'],
                orElse: () => AsyncImageType.midjourney),
        imaginePath: json['imaginePath'],
        fetchPath: json['fetchPath'],
      );
}
