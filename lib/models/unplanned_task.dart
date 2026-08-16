import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'activity.dart';

/// Priorité d'une tâche imprévue
enum TaskPriority {
  urgent,
  normal,
  low,
}

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.normal:
        return 'Normal';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.urgent:
        return const Color(0xFFEF4444); // Rouge vif
      case TaskPriority.normal:
        return const Color(0xFFF59E0B); // Ambre / Orange
      case TaskPriority.low:
        return const Color(0xFF10B981); // Émeraude / Vert
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.urgent:
        return Icons.bolt_rounded;
      case TaskPriority.normal:
        return Icons.flag_rounded;
      case TaskPriority.low:
        return Icons.low_priority_rounded;
    }
  }
}

/// Modèle pour une tâche imprévue / rapide / to-do
class UnplannedTask extends HiveObject {
  final String id;
  final String title;
  final String? description;
  final DateTime date; // Date prévue pour la réalisation
  final TaskPriority priority;
  final ActivityCategory category;
  final bool isCompleted;
  final String? targetTime; // ex: "14:30" optionnel
  final int? estimatedMinutes; // ex: 15, 30, 45, 60 minutes
  final DateTime createdAt;
  final List<String> comments; // Commentaires horodatés
  final int postponedCount; // Nombre de fois où la tâche a été reportée
  final DateTime? originalDate; // Date initiale si reportée

  UnplannedTask({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.priority = TaskPriority.normal,
    this.category = ActivityCategory.autre,
    this.isCompleted = false,
    this.targetTime,
    this.estimatedMinutes,
    DateTime? createdAt,
    List<String>? comments,
    this.postponedCount = 0,
    this.originalDate,
  })  : createdAt = createdAt ?? DateTime.now(),
        comments = comments ?? [];

  /// Obtenir le jour de la semaine (1 = Lundi .. 7 = Dimanche)
  int get dayOfWeek => date.weekday;

  /// Vérifie si la tâche est prévue pour aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifie si la tâche date d'un jour antérieur à aujourd'hui et n'est pas complétée
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    return taskDay.isBefore(today);
  }

  UnplannedTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TaskPriority? priority,
    ActivityCategory? category,
    bool? isCompleted,
    String? targetTime,
    int? estimatedMinutes,
    DateTime? createdAt,
    List<String>? comments,
    int? postponedCount,
    DateTime? originalDate,
  }) {
    return UnplannedTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      targetTime: targetTime ?? this.targetTime,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? List.from(this.comments),
      postponedCount: postponedCount ?? this.postponedCount,
      originalDate: originalDate ?? this.originalDate,
    );
  }
}

/// Adaptateur Hive pour TaskPriority (typeId: 2)
class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 2;

  @override
  TaskPriority read(BinaryReader reader) {
    final index = reader.readByte();
    if (index >= 0 && index < TaskPriority.values.length) {
      return TaskPriority.values[index];
    }
    return TaskPriority.normal;
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeByte(obj.index);
  }
}

/// Adaptateur Hive pour UnplannedTask (typeId: 3)
class UnplannedTaskAdapter extends TypeAdapter<UnplannedTask> {
  @override
  final int typeId = 3;

  @override
  UnplannedTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    List<String> loadedComments = [];
    if (fields[10] != null) {
      if (fields[10] is List) {
        loadedComments = (fields[10] as List).map((e) => e.toString()).toList();
      }
    }

    return UnplannedTask(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      date: fields[3] != null ? DateTime.parse(fields[3] as String) : DateTime.now(),
      priority: fields[4] as TaskPriority? ?? TaskPriority.normal,
      category: fields[5] as ActivityCategory? ?? ActivityCategory.autre,
      isCompleted: fields[6] as bool? ?? false,
      targetTime: fields[7] as String?,
      estimatedMinutes: fields[8] as int?,
      createdAt: fields[9] != null ? DateTime.parse(fields[9] as String) : DateTime.now(),
      comments: loadedComments,
      postponedCount: fields[11] as int? ?? 0,
      originalDate: fields[12] != null ? DateTime.parse(fields[12] as String) : null,
    );
  }

  @override
  void write(BinaryWriter writer, UnplannedTask obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date.toIso8601String())
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.targetTime)
      ..writeByte(8)
      ..write(obj.estimatedMinutes)
      ..writeByte(9)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(10)
      ..write(obj.comments)
      ..writeByte(11)
      ..write(obj.postponedCount)
      ..writeByte(12)
      ..write(obj.originalDate?.toIso8601String());
  }
}
