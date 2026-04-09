// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bite_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BiteEventAdapter extends TypeAdapter<BiteEvent> {
  @override
  final int typeId = 0;

  @override
  BiteEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BiteEvent(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      note: fields[2] as String?,
      finger: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BiteEvent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.finger);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiteEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
