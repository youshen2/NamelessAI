// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatSessionAdapter extends TypeAdapter<ChatSession> {
  @override
  final int typeId = 3;

  @override
  ChatSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatSession(
      id: fields[0] as String?,
      name: fields[1] as String,
      providerId: fields[2] as String?,
      modelId: fields[3] as String?,
      messages: (fields[4] as List?)?.cast<ChatMessage>(),
      systemPrompt: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
      temperature: fields[8] as double?,
      topP: fields[9] as double?,
      branches: (fields[10] as Map?)?.map((dynamic k, dynamic v) => MapEntry(
          k as String,
          (v as List)
              .map((dynamic e) => (e as List).cast<ChatMessage>())
              .toList())),
      activeBranchSelections: (fields[11] as Map?)?.cast<String, int>(),
      useStreaming: fields[12] as bool?,
      maxContextMessages: fields[13] as int?,
      imageSize: fields[14] as String?,
      imageQuality: fields[15] as String?,
      imageStyle: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatSession obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.providerId)
      ..writeByte(3)
      ..write(obj.modelId)
      ..writeByte(4)
      ..write(obj.messages)
      ..writeByte(5)
      ..write(obj.systemPrompt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.temperature)
      ..writeByte(9)
      ..write(obj.topP)
      ..writeByte(10)
      ..write(obj.branches)
      ..writeByte(11)
      ..write(obj.activeBranchSelections)
      ..writeByte(12)
      ..write(obj.useStreaming)
      ..writeByte(13)
      ..write(obj.maxContextMessages)
      ..writeByte(14)
      ..write(obj.imageSize)
      ..writeByte(15)
      ..write(obj.imageQuality)
      ..writeByte(16)
      ..write(obj.imageStyle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
