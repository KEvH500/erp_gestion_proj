import 'package:drift/drift.dart';
import '../database.dart';

part 'task_dao.g.dart';

class TaskWithRecurrence {
  final Task task;
  final RecurrenceRuleEntry? recurrenceRule;
  final List<RecurrenceExceptionEntry> exceptions;

  TaskWithRecurrence({
    required this.task,
    this.recurrenceRule,
    this.exceptions = const [],
  });
}

@DriftAccessor(tables: [Tasks, Projects, RecurrenceRules, RecurrenceExceptions])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // Streams réactifs
  Stream<List<Task>> watchActiveTasks() {
    return (select(tasks)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.startDate),
            (t) => OrderingTerm.asc(t.startHour),
            (t) => OrderingTerm.asc(t.startMinute),
          ]))
        .watch();
  }

  Stream<List<TaskWithRecurrence>> watchActiveTasksWithRecurrence() {
    final query = select(tasks).join([
      leftOuterJoin(
        recurrenceRules,
        recurrenceRules.id.equalsExp(tasks.recurrenceRuleId),
      ),
    ])
      ..where(tasks.isArchived.equals(false))
      ..orderBy([
        OrderingTerm.asc(tasks.startDate),
        OrderingTerm.asc(tasks.startHour),
        OrderingTerm.asc(tasks.startMinute),
      ]);

    return query.watch().asyncMap((rows) async {
      final taskIds = rows.map((r) => r.readTable(tasks).id).toList();
      final allExceptions = taskIds.isNotEmpty
          ? await (select(recurrenceExceptions)
                ..where((e) => e.taskId.isIn(taskIds)))
              .get()
          : <RecurrenceExceptionEntry>[];

      return rows.map((row) {
        final task = row.readTable(tasks);
        final taskExceptions =
            allExceptions.where((e) => e.taskId == task.id).toList();
        return TaskWithRecurrence(
          task: task,
          recurrenceRule: row.readTableOrNull(recurrenceRules),
          exceptions: taskExceptions,
        );
      }).toList();
    });
  }

  Stream<List<Task>> watchTasksForProject(int projectId) {
    return (select(tasks)
          ..where((t) => t.projectId.equals(projectId) & t.isArchived.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.startDate),
            (t) => OrderingTerm.asc(t.startHour),
          ]))
        .watch();
  }

  Stream<List<Task>> watchArchivedTasks() {
    return (select(tasks)
          ..where((t) => t.isArchived.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.archivedAt)]))
        .watch();
  }

  Stream<Task?> watchTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  // Méthodes ponctuelles
  Future<List<Task>> getActiveTasks() {
    return (select(tasks)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.startDate),
            (t) => OrderingTerm.asc(t.startHour),
            (t) => OrderingTerm.asc(t.startMinute),
          ]))
        .get();
  }

  Future<List<TaskWithRecurrence>> getActiveTasksWithRecurrence() async {
    final query = select(tasks).join([
      leftOuterJoin(
        recurrenceRules,
        recurrenceRules.id.equalsExp(tasks.recurrenceRuleId),
      ),
    ])
      ..where(tasks.isArchived.equals(false))
      ..orderBy([
        OrderingTerm.asc(tasks.startDate),
        OrderingTerm.asc(tasks.startHour),
        OrderingTerm.asc(tasks.startMinute),
      ]);

    final rows = await query.get();
    final taskIds = rows.map((r) => r.readTable(tasks).id).toList();
    final allExceptions = taskIds.isNotEmpty
        ? await (select(recurrenceExceptions)
              ..where((e) => e.taskId.isIn(taskIds)))
            .get()
        : <RecurrenceExceptionEntry>[];

    return rows.map((row) {
      final task = row.readTable(tasks);
      final taskExceptions =
          allExceptions.where((e) => e.taskId == task.id).toList();
      return TaskWithRecurrence(
        task: task,
        recurrenceRule: row.readTableOrNull(recurrenceRules),
        exceptions: taskExceptions,
      );
    }).toList();
  }

  Future<List<Task>> getArchivedTasks() {
    return (select(tasks)
          ..where((t) => t.isArchived.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.archivedAt)]))
        .get();
  }

  Future<Task?> getTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Exceptions de récurrence
  Future<int> upsertException(RecurrenceExceptionsCompanion exception) {
    return into(recurrenceExceptions).insertOnConflictUpdate(exception);
  }

  Future<List<RecurrenceExceptionEntry>> getExceptionsForTask(int taskId) {
    return (select(recurrenceExceptions)..where((e) => e.taskId.equals(taskId)))
        .get();
  }

  Future<RecurrenceExceptionEntry?> getException(
      int taskId, DateTime originalDate) {
    final normalized =
        DateTime(originalDate.year, originalDate.month, originalDate.day);
    return (select(recurrenceExceptions)
          ..where((e) =>
              e.taskId.equals(taskId) & e.originalDate.equals(normalized)))
        .getSingleOrNull();
  }

  Future<int> deleteException(int id) {
    return (delete(recurrenceExceptions)..where((e) => e.id.equals(id))).go();
  }

  Future<int> deleteExceptionByOriginalDate(int taskId, DateTime originalDate) {
    final normalized =
        DateTime(originalDate.year, originalDate.month, originalDate.day);
    return (delete(recurrenceExceptions)
          ..where((e) =>
              e.taskId.equals(taskId) & e.originalDate.equals(normalized)))
        .go();
  }

  // CRUD
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  Future<int> insertRecurrenceRule(RecurrenceRulesCompanion rule) =>
      into(recurrenceRules).insert(rule);

  Future<bool> updateTask(Task task) =>
      update(tasks).replace(task.copyWith(updatedAt: DateTime.now()));

  Future<int> toggleTaskCompletion(int id) async {
    final task = await getTaskById(id);
    if (task == null) return 0;
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: Value(!task.isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> archiveTask(int id) {
    final now = DateTime.now();
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isArchived: const Value(true),
        archivedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> restoreTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isArchived: const Value(false),
        archivedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }
}
