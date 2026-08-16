import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../models/activity.dart';
import 'daos/project_dao.dart';
import 'daos/task_dao.dart';
import 'daos/task_comment_dao.dart';

part 'database.g.dart';

/// Table `projects`
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF3B82F6))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

/// Table `tasks` (concept enrichi de l'ancienne entité Activity)
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()
      .nullable()
      .references(Projects, #id, onDelete: KeyAction.setNull)();

  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  // Calendrier et créneau horaire
  IntColumn get dayOfWeek => integer()(); // 1 = Lundi, 7 = Dimanche
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();

  // Métadonnées
  IntColumn get category => intEnum<ActivityCategory>()();
  TextColumn get location => text().nullable()();
  IntColumn get reminderMinutesBefore => integer().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(true))();
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();

  // Couleurs et statuts
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF3B82F6))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  // Horodatages
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Table `task_comments`
class TaskComments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer()
      .references(Tasks, #id, onDelete: KeyAction.cascade)();

  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [Projects, Tasks, TaskComments],
  daos: [ProjectDao, TaskDao, TaskCommentDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_drift.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
