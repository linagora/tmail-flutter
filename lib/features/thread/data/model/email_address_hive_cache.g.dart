// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_address_hive_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailAddressHiveCacheAdapter extends TypeAdapter<EmailAddressHiveCache> {
  @override
  final int typeId = 6;

  @override
  EmailAddressHiveCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmailAddressHiveCache(
      fields[0] as String?,
      fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmailAddressHiveCache obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddressHiveCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
