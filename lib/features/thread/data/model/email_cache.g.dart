// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailCacheAdapter extends TypeAdapter<EmailCache> {
  @override
  final int typeId = 5;

  @override
  EmailCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmailCache(
      fields[0] as String,
      keywords: (fields[1] as Map?)?.cast<String, bool>(),
      size: fields[2] as int?,
      receivedAt: fields[3] as DateTime?,
      hasAttachment: fields[4] as bool?,
      preview: fields[5] as String?,
      subject: fields[6] as String?,
      sentAt: fields[7] as DateTime?,
      from: (fields[8] as List?)?.cast<EmailAddressHiveCache>(),
      to: (fields[9] as List?)?.cast<EmailAddressHiveCache>(),
      cc: (fields[10] as List?)?.cast<EmailAddressHiveCache>(),
      bcc: (fields[11] as List?)?.cast<EmailAddressHiveCache>(),
      replyTo: (fields[12] as List?)?.cast<EmailAddressHiveCache>(),
    );
  }

  @override
  void write(BinaryWriter writer, EmailCache obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.keywords)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.receivedAt)
      ..writeByte(4)
      ..write(obj.hasAttachment)
      ..writeByte(5)
      ..write(obj.preview)
      ..writeByte(6)
      ..write(obj.subject)
      ..writeByte(7)
      ..write(obj.sentAt)
      ..writeByte(8)
      ..write(obj.from)
      ..writeByte(9)
      ..write(obj.to)
      ..writeByte(10)
      ..write(obj.cc)
      ..writeByte(11)
      ..write(obj.bcc)
      ..writeByte(12)
      ..write(obj.replyTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
