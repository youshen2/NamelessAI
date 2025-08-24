import 'package:hive/hive.dart';

part 'model_type.g.dart';

@HiveType(typeId: 5)
enum ModelType {
  @HiveField(0)
  language,

  @HiveField(1)
  image,

  @HiveField(2)
  video,

  @HiveField(3)
  tts,
}
