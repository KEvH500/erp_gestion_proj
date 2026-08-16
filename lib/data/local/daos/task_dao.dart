import 'package:drift/drift.dart';
import '../database.dart';

part 'task_dao.g.dart';

class TaskWithRecurrence {
  final Task task;
  final RecurrenceRuleEntry? recurrenceRule;

  TaskWithRecurrence({
    required this.task,
    this.recurrenceRule,
  });
}

@DriftAccessor(tables: [Tasks, Projects, RecurrenceRules])
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

    return query.watch().map((rows) {
      return rows.map((row) {
        return TaskWithRecurrence(
          task: row.readTable(tasks),
          recurrenceRule: row.readTableOrNull(recurrenceRules),
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
    return rows.map((row) {
      return TaskWithRecurrence(
        task: row.readTable(tasks),
        recurrenceRule: row.readTableOrNull(recurrenceRules),
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
