import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../models/activity.dart';
import '../../models/recurrence_rule.dart';
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

/// Table `recurrence_rules`
@DataClassName('RecurrenceRuleEntry')
class RecurrenceRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get frequency => intEnum<RecurrenceFrequency>()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  TextColumn get byWeekDays => text().nullable()();
  IntColumn get endType => intEnum<RecurrenceEndType>().withDefault(const Constant(0))();
  DateTimeColumn get untilDate => dateTime().nullable()();
  IntColumn get occurrenceCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Table `tasks` (concept enrichi avec récurrence universelle)
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()
      .nullable()
      .references(Projects, #id, onDelete: KeyAction.setNull)();

  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  // Calendrier et créneau horaire
  DateTimeColumn get startDate => dateTime()(); // Date réelle de début / ancrage
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();

  // Règle de récurrence (nullable -> null = tâche ponctuelle)
  IntColumn get recurrenceRuleId => integer()
      .nullable()
      .references(RecurrenceRules, #id, onDelete: KeyAction.setNull)();

  // Métadonnées
  IntColumn get category => intEnum<ActivityCategory>()();
  TextColumn get location => text().nullable()();
  IntColumn get reminderMinutesBefore => integer().nullable()();

  // Couleurs et statuts
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF3B82F6))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

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

/// Table `recurrence_exceptions`
@DataClassName('RecurrenceExceptionEntry')
class RecurrenceExceptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('taskExceptions')
  IntColumn get taskId => integer()
      .references(Tasks, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get originalDate => dateTime()();
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();
  BoolColumn get isDetached => boolean().withDefault(const Constant(false))();

  @ReferenceName('detachedExceptions')
  IntColumn get detachedTaskId => integer()
      .nullable()
      .references(Tasks, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get newDate => dateTime().nullable()();
  DateTimeColumn get newStartTime => dateTime().nullable()();
  DateTimeColumn get newEndTime => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {taskId, originalDate},
      ];
}

@DriftDatabase(
  tables: [Projects, RecurrenceRules, Tasks, TaskComments, RecurrenceExceptions],
  daos: [ProjectDao, TaskDao, TaskCommentDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(recurrenceRules);
        await m.addColumn(tasks, tasks.startDate);
        await m.addColumn(tasks, tasks.recurrenceRuleId);
      }
      if (from < 3) {
        await m.createTable(recurrenceExceptions);
      }
      if (from < 4) {
        await m.addColumn(tasks, tasks.isLocked);
      }
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
