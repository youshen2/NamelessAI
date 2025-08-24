// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelTypeAdapter extends TypeAdapter<ModelType> {
  @override
  final int typeId = 5;

  @override
  ModelType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ModelType.language;
      case 1:
        return ModelType.image;
      case 2:
        return ModelType.video;
      case 3:
        return ModelType.tts;
      default:
        return ModelType.language;
    }
  }

  @override
  void write(BinaryWriter writer, ModelType obj) {
    switch (obj) {
      case ModelType.language:
        writer.writeByte(0);
        break;
      case ModelType.image:
        writer.writeByte(1);
        break;
      case ModelType.video:
        writer.writeByte(2);
        break;
      case ModelType.tts:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
