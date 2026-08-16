// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_exception.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurrenceExceptionAdapter extends TypeAdapter<RecurrenceException> {
  @override
  final int typeId = 10;

  @override
  RecurrenceException read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurrenceException(
      id: fields[0] as String?,
      taskId: fields[1] as String,
      originalDate: fields[2] as DateTime,
      isCancelled: fields[3] as bool,
      isDetached: fields[4] as bool,
      detachedTaskId: fields[5] as String?,
      newDate: fields[6] as DateTime?,
      newStartTime: fields[7] as DateTime?,
      newEndTime: fields[8] as DateTime?,
      newStartHour: fields[9] as int?,
      newStartMinute: fields[10] as int?,
      newEndHour: fields[11] as int?,
      newEndMinute: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurrenceException obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.originalDate)
      ..writeByte(3)
      ..write(obj.isCancelled)
      ..writeByte(4)
      ..write(obj.isDetached)
      ..writeByte(5)
      ..write(obj.detachedTaskId)
      ..writeByte(6)
      ..write(obj.newDate)
      ..writeByte(7)
      ..write(obj.newStartTime)
      ..writeByte(8)
      ..write(obj.newEndTime)
      ..writeByte(9)
      ..write(obj.newStartHour)
      ..writeByte(10)
      ..write(obj.newStartMinute)
      ..writeByte(11)
      ..write(obj.newEndHour)
      ..writeByte(12)
      ..write(obj.newEndMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceExceptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
