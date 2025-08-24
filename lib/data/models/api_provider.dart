import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:nameless_ai/data/models/model.dart';

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

  APIProvider({
    String? id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    List<Model>? models,
  })  : id = id ?? const Uuid().v4(),
        models = models ?? [];

  APIProvider copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    List<Model>? models,
  }) {
    return APIProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      models: models ?? this.models,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'models': models.map((m) => m.toJson()).toList(),
      };

  factory APIProvider.fromJson(Map<String, dynamic> json) => APIProvider(
        id: json['id'],
        name: json['name'],
        baseUrl: json['baseUrl'],
        apiKey: json['apiKey'],
        models: (json['models'] as List).map((m) => Model.fromJson(m)).toList(),
      );
}
