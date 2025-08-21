// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 2;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: fields[0] as String?,
      role: fields[1] as String,
      content: fields[2] as String,
      timestamp: fields[3] as DateTime?,
      isEditing: fields[4] == null ? false : fields[4] as bool,
      isLoading: fields[5] == null ? false : fields[5] as bool,
      promptTokens: fields[6] as int?,
      completionTokens: fields[7] as int?,
      completionTimeMs: fields[8] as int?,
      firstChunkTimeMs: fields[9] as int?,
      outputCharacters: fields[10] as int?,
      isError: fields[11] == null ? false : fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.isEditing)
      ..writeByte(5)
      ..write(obj.isLoading)
      ..writeByte(6)
      ..write(obj.promptTokens)
      ..writeByte(7)
      ..write(obj.completionTokens)
      ..writeByte(8)
      ..write(obj.completionTimeMs)
      ..writeByte(9)
      ..write(obj.firstChunkTimeMs)
      ..writeByte(10)
      ..write(obj.outputCharacters)
      ..writeByte(11)
      ..write(obj.isError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
