// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StateCacheAdapter extends TypeAdapter<StateCache> {
  @override
  final int typeId = 3;

  @override
  StateCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StateCache(
      fields[0] as StateType,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StateCache obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
