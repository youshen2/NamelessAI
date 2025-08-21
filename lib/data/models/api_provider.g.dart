// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class APIProviderAdapter extends TypeAdapter<APIProvider> {
  @override
  final int typeId = 0;

  @override
  APIProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return APIProvider(
      id: fields[0] as String?,
      name: fields[1] as String,
      baseUrl: fields[2] as String,
      apiKey: fields[3] as String,
      models: (fields[4] as List?)?.cast<Model>(),
      chatCompletionPath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, APIProvider obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.baseUrl)
      ..writeByte(3)
      ..write(obj.apiKey)
      ..writeByte(4)
      ..write(obj.models)
      ..writeByte(5)
      ..write(obj.chatCompletionPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APIProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModelAdapter extends TypeAdapter<Model> {
  @override
  final int typeId = 1;

  @override
  Model read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Model(
      id: fields[0] as String?,
      name: fields[1] as String,
      maxTokens: fields[2] as int?,
      isStreamable: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Model obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.maxTokens)
      ..writeByte(3)
      ..write(obj.isStreamable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
