import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'activity.dart';

/// Type d'objectif : Temps limité (échéance/compte à rebours), Temps plein (durée cible), ou Nombre de tâches
enum GoalType {
  timeLimited, // ex: Avant 17h00 ou en 2 heures max
  fullTime,    // ex: 8h de travail sur la journée ou 35h/semaine
  taskCount,   // ex: 5 tâches accomplies
}

extension GoalTypeExtension on GoalType {
  String get label {
    switch (this) {
      case GoalType.timeLimited:
        return 'Temps Limité ⏱️';
      case GoalType.fullTime:
        return 'Temps Plein ⏳';
      case GoalType.taskCount:
        return 'Volume Tâches 📋';
    }
  }

  Color get color {
    switch (this) {
      case GoalType.timeLimited:
        return const Color(0xFFEC4899); // Rose / Magenta dynamique
      case GoalType.fullTime:
        return const Color(0xFF3B82F6); // Bleu éclatant
      case GoalType.taskCount:
        return const Color(0xFF10B981); // Émeraude
    }
  }

  IconData get icon {
    switch (this) {
      case GoalType.timeLimited:
        return Icons.timer_outlined;
      case GoalType.fullTime:
        return Icons.hourglass_top_rounded;
      case GoalType.taskCount:
        return Icons.checklist_rounded;
    }
  }
}

/// Période de l'objectif
enum GoalPeriod {
  daily,  // Quotidien / du jour
  weekly, // Hebdomadaire
  custom, // Ponctuel / Spécifique
}

extension GoalPeriodExtension on GoalPeriod {
  String get label {
    switch (this) {
      case GoalPeriod.daily:
        return 'Journalier';
      case GoalPeriod.weekly:
        return 'Hebdomadaire';
      case GoalPeriod.custom:
        return 'Personnalisé';
    }
  }
}

/// Modèle pour un Objectif
class Goal extends HiveObject {
  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalPeriod period;
  final ActivityCategory? category; // Catégorie ciblée (optionnel)
  final double targetValue; // ex: 480 (minutes pour 8h), 5 (tâches)
  final double currentValue; // progression actuelle
  final DateTime? deadline; // Date/heure limite pour les objectifs à temps limité
  final DateTime startDate;
  final bool isCompleted;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.period = GoalPeriod.daily,
    this.category,
    required this.targetValue,
    this.currentValue = 0.0,
    this.deadline,
    DateTime? startDate,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : startDate = startDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// Pourcentage d'accomplissement (entre 0.0 et 1.0)
  double get progressPercentage {
    if (targetValue <= 0) return isCompleted ? 1.0 : 0.0;
    final progress = currentValue / targetValue;
    return progress.clamp(0.0, 1.0);
  }

  /// Pourcentage d'accomplissement formaté (ex: "85%")
  String get progressPercentageFormatted {
    return '${(progressPercentage * 100).toInt()}%';
  }

  /// Indique si l'objectif à temps limité est expiré
  bool get isExpired {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Temps restant avant deadline pour objectif à temps limité
  String? get timeRemainingFormatted {
    if (deadline == null) return null;
    final now = DateTime.now();
    if (now.isAfter(deadline!)) {
      final diff = now.difference(deadline!);
      if (diff.inHours > 0) return 'Expiré de ${diff.inHours}h ${diff.inMinutes % 60}m';
      return 'Expiré de ${diff.inMinutes}m';
    }
    final diff = deadline!.difference(now);
    if (diff.inDays > 0) return '${diff.inDays}j ${diff.inHours % 24}h restant';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m restant';
    return '${diff.inMinutes} min restantes';
  }

  /// Affichage lisible de la cible et de l'actuel
  String get progressDisplay {
    if (type == GoalType.taskCount) {
      return '${currentValue.toInt()} / ${targetValue.toInt()} tâches';
    } else {
      // Affichage en heures / minutes
      final currentHours = (currentValue / 60).toStringAsFixed(1);
      final targetHours = (targetValue / 60).toStringAsFixed(1);
      return '${currentHours}h / ${targetHours}h';
    }
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalPeriod? period,
    ActivityCategory? category,
    double? targetValue,
    double? currentValue,
    DateTime? deadline,
    DateTime? startDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      period: period ?? this.period,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
      startDate: startDate ?? this.startDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Adaptateur Hive pour GoalType (typeId: 4)
class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 4;

  @override
  GoalType read(BinaryReader reader) {
    final index = reader.readByte();
    if (index >= 0 && index < GoalType.values.length) {
      return GoalType.values[index];
    }
    return GoalType.fullTime;
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    writer.writeByte(obj.index);
  }
}

/// Adaptateur Hive pour GoalPeriod (typeId: 5)
class GoalPeriodAdapter extends TypeAdapter<GoalPeriod> {
  @override
  final int typeId = 5;

  @override
  GoalPeriod read(BinaryReader reader) {
    final index = reader.readByte();
    if (index >= 0 && index < GoalPeriod.values.length) {
      return GoalPeriod.values[index];
    }
    return GoalPeriod.daily;
  }

  @override
  void write(BinaryWriter writer, GoalPeriod obj) {
    writer.writeByte(obj.index);
  }
}

/// Adaptateur Hive pour Goal (typeId: 6)
class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 6;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as GoalType? ?? GoalType.fullTime,
      period: fields[4] as GoalPeriod? ?? GoalPeriod.daily,
      category: fields[5] as ActivityCategory?,
      targetValue: (fields[6] as num?)?.toDouble() ?? 0.0,
      currentValue: (fields[7] as num?)?.toDouble() ?? 0.0,
      deadline: fields[8] != null ? DateTime.parse(fields[8] as String) : null,
      startDate: fields[9] != null ? DateTime.parse(fields[9] as String) : DateTime.now(),
      isCompleted: fields[10] as bool? ?? false,
      createdAt: fields[11] != null ? DateTime.parse(fields[11] as String) : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.period)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.targetValue)
      ..writeByte(7)
      ..write(obj.currentValue)
      ..writeByte(8)
      ..write(obj.deadline?.toIso8601String())
      ..writeByte(9)
      ..write(obj.startDate.toIso8601String())
      ..writeByte(10)
      ..write(obj.isCompleted)
      ..writeByte(11)
      ..write(obj.createdAt.toIso8601String());
  }
}
