import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'system_prompt_template.g.dart';

@HiveType(typeId: 4)
class SystemPromptTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String prompt;

  SystemPromptTemplate({
    String? id,
    required this.name,
    required this.prompt,
  }) : id = id ?? const Uuid().v4();

  SystemPromptTemplate copyWith({
    String? id,
    String? name,
    String? prompt,
  }) {
    return SystemPromptTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
    );
  }
}
