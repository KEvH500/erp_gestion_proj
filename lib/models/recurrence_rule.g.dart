// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = 9;

  @override
  RecurrenceRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurrenceRule(
      id: fields[0] as String,
      frequency: fields[1] as RecurrenceFrequency,
      interval: fields[2] as int,
      byWeekDays: fields[3] as String?,
      endType: fields[4] as RecurrenceEndType,
      untilDate: fields[5] as DateTime?,
      occurrenceCount: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.frequency)
      ..writeByte(2)
      ..write(obj.interval)
      ..writeByte(3)
      ..write(obj.byWeekDays)
      ..writeByte(4)
      ..write(obj.endType)
      ..writeByte(5)
      ..write(obj.untilDate)
      ..writeByte(6)
      ..write(obj.occurrenceCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceFrequencyAdapter extends TypeAdapter<RecurrenceFrequency> {
  @override
  final int typeId = 7;

  @override
  RecurrenceFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceFrequency.daily;
      case 1:
        return RecurrenceFrequency.weekly;
      case 2:
        return RecurrenceFrequency.monthly;
      default:
        return RecurrenceFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceFrequency obj) {
    switch (obj) {
      case RecurrenceFrequency.daily:
        writer.writeByte(0);
        break;
      case RecurrenceFrequency.weekly:
        writer.writeByte(1);
        break;
      case RecurrenceFrequency.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceEndTypeAdapter extends TypeAdapter<RecurrenceEndType> {
  @override
  final int typeId = 8;

  @override
  RecurrenceEndType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceEndType.never;
      case 1:
        return RecurrenceEndType.untilDate;
      case 2:
        return RecurrenceEndType.count;
      default:
        return RecurrenceEndType.never;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceEndType obj) {
    switch (obj) {
      case RecurrenceEndType.never:
        writer.writeByte(0);
        break;
      case RecurrenceEndType.untilDate:
        writer.writeByte(1);
        break;
      case RecurrenceEndType.count:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceEndTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
