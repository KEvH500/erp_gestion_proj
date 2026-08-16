// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 1;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      dayOfWeek: fields[3] as int,
      startHour: fields[4] as int,
      startMinute: fields[5] as int,
      endHour: fields[6] as int,
      endMinute: fields[7] as int,
      category: fields[8] as ActivityCategory,
      isCompleted: fields[9] as bool,
      location: fields[10] as String?,
      reminderMinutesBefore: fields[11] as int?,
      isRecurring: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dayOfWeek)
      ..writeByte(4)
      ..write(obj.startHour)
      ..writeByte(5)
      ..write(obj.startMinute)
      ..writeByte(6)
      ..write(obj.endHour)
      ..writeByte(7)
      ..write(obj.endMinute)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.location)
      ..writeByte(11)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(12)
      ..write(obj.isRecurring);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityCategoryAdapter extends TypeAdapter<ActivityCategory> {
  @override
  final int typeId = 0;

  @override
  ActivityCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityCategory.cours;
      case 1:
        return ActivityCategory.travail;
      case 2:
        return ActivityCategory.perso;
      case 3:
        return ActivityCategory.sport;
      case 4:
        return ActivityCategory.autre;
      default:
        return ActivityCategory.cours;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityCategory obj) {
    switch (obj) {
      case ActivityCategory.cours:
        writer.writeByte(0);
        break;
      case ActivityCategory.travail:
        writer.writeByte(1);
        break;
      case ActivityCategory.perso:
        writer.writeByte(2);
        break;
      case ActivityCategory.sport:
        writer.writeByte(3);
        break;
      case ActivityCategory.autre:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
