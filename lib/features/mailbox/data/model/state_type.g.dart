// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StateTypeAdapter extends TypeAdapter<StateType> {
  @override
  final int typeId = 4;

  @override
  StateType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StateType.mailbox;
      default:
        return StateType.mailbox;
    }
  }

  @override
  void write(BinaryWriter writer, StateType obj) {
    switch (obj) {
      case StateType.mailbox:
        writer.writeByte(0);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
