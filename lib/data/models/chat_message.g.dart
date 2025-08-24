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
      modelName: fields[12] as String?,
      thinkingContent: fields[13] as String?,
      thinkingDurationMs: fields[14] as int?,
      messageType:
          fields[15] == null ? MessageType.text : fields[15] as MessageType,
      taskId: fields[16] as String?,
      asyncTaskStatus: fields[17] == null
          ? AsyncTaskStatus.none
          : fields[17] as AsyncTaskStatus,
      asyncTaskProgress: fields[18] as String?,
      asyncTaskFullResponse: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(20)
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
      ..write(obj.isError)
      ..writeByte(12)
      ..write(obj.modelName)
      ..writeByte(13)
      ..write(obj.thinkingContent)
      ..writeByte(14)
      ..write(obj.thinkingDurationMs)
      ..writeByte(15)
      ..write(obj.messageType)
      ..writeByte(16)
      ..write(obj.taskId)
      ..writeByte(17)
      ..write(obj.asyncTaskStatus)
      ..writeByte(18)
      ..write(obj.asyncTaskProgress)
      ..writeByte(19)
      ..write(obj.asyncTaskFullResponse);
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

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 15;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.image:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AsyncTaskStatusAdapter extends TypeAdapter<AsyncTaskStatus> {
  @override
  final int typeId = 18;

  @override
  AsyncTaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AsyncTaskStatus.none;
      case 1:
        return AsyncTaskStatus.submitted;
      case 2:
        return AsyncTaskStatus.inProgress;
      case 3:
        return AsyncTaskStatus.failure;
      case 4:
        return AsyncTaskStatus.success;
      default:
        return AsyncTaskStatus.none;
    }
  }

  @override
  void write(BinaryWriter writer, AsyncTaskStatus obj) {
    switch (obj) {
      case AsyncTaskStatus.none:
        writer.writeByte(0);
        break;
      case AsyncTaskStatus.submitted:
        writer.writeByte(1);
        break;
      case AsyncTaskStatus.inProgress:
        writer.writeByte(2);
        break;
      case AsyncTaskStatus.failure:
        writer.writeByte(3);
        break;
      case AsyncTaskStatus.success:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncTaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
