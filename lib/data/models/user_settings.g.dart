// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      id: fields[0] as String,
      onboardingDone: fields[1] as bool,
      goal: fields[2] as String,
      reminderHour: fields[3] as int,
      reminderMinute: fields[4] as int,
      notificationsEnabled: fields[5] as bool,
      programStartDate: fields[6] as DateTime,
      userName: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.onboardingDone)
      ..writeByte(2)
      ..write(obj.goal)
      ..writeByte(3)
      ..write(obj.reminderHour)
      ..writeByte(4)
      ..write(obj.reminderMinute)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.programStartDate)
      ..writeByte(7)
      ..write(obj.userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
