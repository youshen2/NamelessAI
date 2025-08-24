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
      supportsThinking: fields[4] == null ? false : fields[4] as bool,
      modelType:
          fields[5] == null ? ModelType.language : fields[5] as ModelType,
      imageGenerationMode: fields[6] == null
          ? ImageGenerationMode.instant
          : fields[6] as ImageGenerationMode,
      asyncImageType: fields[7] as AsyncImageType?,
      imaginePath: fields[8] as String?,
      fetchPath: fields[9] as String?,
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
      ..write(obj.supportsThinking)
      ..writeByte(5)
      ..write(obj.modelType)
      ..writeByte(6)
      ..write(obj.imageGenerationMode)
      ..writeByte(7)
      ..write(obj.asyncImageType)
      ..writeByte(8)
      ..write(obj.imaginePath)
      ..writeByte(9)
      ..write(obj.fetchPath);
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

class AsyncImageTypeAdapter extends TypeAdapter<AsyncImageType> {
  @override
  final int typeId = 17;

  @override
  AsyncImageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AsyncImageType.midjourney;
      default:
        return AsyncImageType.midjourney;
    }
  }

  @override
  void write(BinaryWriter writer, AsyncImageType obj) {
    switch (obj) {
      case AsyncImageType.midjourney:
        writer.writeByte(0);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncImageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
