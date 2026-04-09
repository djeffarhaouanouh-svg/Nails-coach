// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyPhotoAdapter extends TypeAdapter<DailyPhoto> {
  @override
  final int typeId = 1;

  @override
  DailyPhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyPhoto(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      localPath: fields[2] as String,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyPhoto obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.localPath)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyPhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
