// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      modelType:
          fields[4] == null ? ModelType.language : fields[4] as ModelType,
      imageGenerationMode: fields[5] == null
          ? ImageGenerationMode.instant
          : fields[5] as ImageGenerationMode,
      compatibilityMode: fields[6] as CompatibilityMode?,
      imaginePath: fields[7] as String?,
      fetchPath: fields[8] as String?,
      chatPath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Model obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.maxTokens)
      ..writeByte(3)
      ..write(obj.isStreamable)
      ..writeByte(4)
      ..write(obj.modelType)
      ..writeByte(5)
      ..write(obj.imageGenerationMode)
      ..writeByte(6)
      ..write(obj.compatibilityMode)
      ..writeByte(7)
      ..write(obj.imaginePath)
      ..writeByte(8)
      ..write(obj.fetchPath)
      ..writeByte(9)
      ..write(obj.chatPath);
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

class ImageGenerationModeAdapter extends TypeAdapter<ImageGenerationMode> {
  @override
  final int typeId = 16;

  @override
  ImageGenerationMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ImageGenerationMode.instant;
      case 1:
        return ImageGenerationMode.asynchronous;
      default:
        return ImageGenerationMode.instant;
    }
  }

  @override
  void write(BinaryWriter writer, ImageGenerationMode obj) {
    switch (obj) {
      case ImageGenerationMode.instant:
        writer.writeByte(0);
        break;
      case ImageGenerationMode.asynchronous:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompatibilityModeAdapter extends TypeAdapter<CompatibilityMode> {
  @override
  final int typeId = 17;

  @override
  CompatibilityMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompatibilityMode.midjourneyProxy;
      default:
        return CompatibilityMode.midjourneyProxy;
    }
  }

  @override
  void write(BinaryWriter writer, CompatibilityMode obj) {
    switch (obj) {
      case CompatibilityMode.midjourneyProxy:
        writer.writeByte(0);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompatibilityModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
