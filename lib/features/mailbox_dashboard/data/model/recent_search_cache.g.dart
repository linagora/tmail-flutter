// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentSearchCacheAdapter extends TypeAdapter<RecentSearchCache> {
  @override
  final int typeId = 7;

  @override
  RecentSearchCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentSearchCache(
      fields[0] as String,
      fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecentSearchCache obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.creationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentSearchCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
