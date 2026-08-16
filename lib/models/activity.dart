import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 0)
enum ActivityCategory {
  @HiveField(0)
  cours,

  @HiveField(1)
  travail,

  @HiveField(2)
  perso,

  @HiveField(3)
  sport,

  @HiveField(4)
  autre,
}

extension ActivityCategoryExtension on ActivityCategory {
  String get label {
    switch (this) {
      case ActivityCategory.cours:
        return 'Cours / Études';
      case ActivityCategory.travail:
        return 'Travail';
      case ActivityCategory.perso:
        return 'Personnel';
      case ActivityCategory.sport:
        return 'Sport / Santé';
      case ActivityCategory.autre:
        return 'Autre';
    }
  }

  Color get color {
    switch (this) {
      case ActivityCategory.cours:
        return const Color(0xFF3B82F6); // Bleu vif
      case ActivityCategory.travail:
        return const Color(0xFF8B5CF6); // Violet moderne
      case ActivityCategory.perso:
        return const Color(0xFF10B981); // Émeraude / Vert
      case ActivityCategory.sport:
        return const Color(0xFFEF4444); // Rouge / Corail
      case ActivityCategory.autre:
        return const Color(0xFF64748B); // Gris ardoise
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityCategory.cours:
        return Icons.school_rounded;
      case ActivityCategory.travail:
        return Icons.work_rounded;
      case ActivityCategory.perso:
        return Icons.person_rounded;
      case ActivityCategory.sport:
        return Icons.fitness_center_rounded;
      case ActivityCategory.autre:
        return Icons.category_rounded;
    }
  }
}

@HiveType(typeId: 1)
class Activity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int dayOfWeek; // 1 = Lundi, 2 = Mardi, ..., 7 = Dimanche (DateTime.monday .. DateTime.sunday)

  @HiveField(4)
  final int startHour;

  @HiveField(5)
  final int startMinute;

  @HiveField(6)
  final int endHour;

  @HiveField(7)
  final int endMinute;

  @HiveField(8)
  final ActivityCategory category;

  @HiveField(9)
  final bool isCompleted;

  @HiveField(10)
  final String? location;

  @HiveField(11)
  final int? reminderMinutesBefore; // ex: 10, 15, 30 min

  @HiveField(12)
  final bool isRecurring;

  Activity({
    required this.id,
    required this.title,
    this.description,
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.category,
    this.isCompleted = false,
    this.location,
    this.reminderMinutesBefore,
    this.isRecurring = true,
  });

  /// Nom du jour en français
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Inconnu';
    }
  }

  /// Heure de début formatée (HH:mm)
  String get startTimeFormatted {
    final h = startHour.toString().padLeft(2, '0');
    final m = startMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Heure de fin formatée (HH:mm)
  String get endTimeFormatted {
    final h = endHour.toString().padLeft(2, '0');
    final m = endMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Plage horaire formatée (ex: "08:30 - 10:00")
  String get timeRangeFormatted => '$startTimeFormatted - $endTimeFormatted';

  /// Durée de l'activité en minutes
  int get durationInMinutes {
    final startTotal = startHour * 60 + startMinute;
    final endTotal = endHour * 60 + endMinute;
    return endTotal - startTotal;
  }

  /// Méthode copyWith pour faciliter les mises à jour immuables
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    int? dayOfWeek,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    ActivityCategory? category,
    bool? isCompleted,
    String? location,
    int? reminderMinutesBefore,
    bool? isRecurring,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, day: $dayName, time: $timeRangeFormatted, category: ${category.name}, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dayOfWeek == dayOfWeek &&
        other.startHour == startHour &&
        other.startMinute == startMinute &&
        other.endHour == endHour &&
        other.endMinute == endMinute &&
        other.category == category &&
        other.isCompleted == isCompleted &&
        other.location == location &&
        other.reminderMinutesBefore == reminderMinutesBefore &&
        other.isRecurring == isRecurring;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      dayOfWeek,
      startHour,
      startMinute,
      endHour,
      endMinute,
      category,
      isCompleted,
      location,
      reminderMinutesBefore,
      isRecurring,
    );
  }
}
