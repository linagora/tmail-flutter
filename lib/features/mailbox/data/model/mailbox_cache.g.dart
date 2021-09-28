// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mailbox_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MailboxCacheAdapter extends TypeAdapter<MailboxCache> {
  @override
  final int typeId = 1;

  @override
  MailboxCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MailboxCache(
      fields[0] as String,
      name: fields[1] as String?,
      parentId: fields[2] as String?,
      role: fields[3] as String?,
      sortOrder: fields[4] as int?,
      totalEmails: fields[5] as int?,
      unreadEmails: fields[6] as int?,
      totalThreads: fields[7] as int?,
      unreadThreads: fields[8] as int?,
      myRights: fields[9] as MailboxRightsCache?,
      isSubscribed: fields[10] as bool?,
      lastOpened: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MailboxCache obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.sortOrder)
      ..writeByte(5)
      ..write(obj.totalEmails)
      ..writeByte(6)
      ..write(obj.unreadEmails)
      ..writeByte(7)
      ..write(obj.totalThreads)
      ..writeByte(8)
      ..write(obj.unreadThreads)
      ..writeByte(9)
      ..write(obj.myRights)
      ..writeByte(10)
      ..write(obj.isSubscribed)
      ..writeByte(11)
      ..write(obj.lastOpened);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailboxCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
