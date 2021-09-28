// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mailbox_rights_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MailboxRightsCacheAdapter extends TypeAdapter<MailboxRightsCache> {
  @override
  final int typeId = 2;

  @override
  MailboxRightsCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MailboxRightsCache(
      fields[0] as bool,
      fields[1] as bool,
      fields[2] as bool,
      fields[3] as bool,
      fields[4] as bool,
      fields[5] as bool,
      fields[6] as bool,
      fields[7] as bool,
      fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MailboxRightsCache obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.mayReadItems)
      ..writeByte(1)
      ..write(obj.mayAddItems)
      ..writeByte(2)
      ..write(obj.mayRemoveItems)
      ..writeByte(3)
      ..write(obj.maySetSeen)
      ..writeByte(4)
      ..write(obj.maySetKeywords)
      ..writeByte(5)
      ..write(obj.mayCreateChild)
      ..writeByte(6)
      ..write(obj.mayRename)
      ..writeByte(7)
      ..write(obj.mayDelete)
      ..writeByte(8)
      ..write(obj.maySubmit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailboxRightsCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
