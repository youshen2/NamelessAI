// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_prompt_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemPromptTemplateAdapter extends TypeAdapter<SystemPromptTemplate> {
  @override
  final int typeId = 4;

  @override
  SystemPromptTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemPromptTemplate(
      id: fields[0] as String?,
      name: fields[1] as String,
      prompt: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SystemPromptTemplate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.prompt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemPromptTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
