import 'package:drift/drift.dart';
import '../database.dart';

part 'task_comment_dao.g.dart';

@DriftAccessor(tables: [TaskComments])
class TaskCommentDao extends DatabaseAccessor<AppDatabase> with _$TaskCommentDaoMixin {
  TaskCommentDao(super.db);

  // Streams réactifs
  Stream<List<TaskComment>> watchCommentsForTask(int taskId) {
    return (select(taskComments)
          ..where((c) => c.taskId.equals(taskId))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
        .watch();
  }

  // Méthodes ponctuelles
  Future<List<TaskComment>> getCommentsForTask(int taskId) {
    return (select(taskComments)
          ..where((c) => c.taskId.equals(taskId))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
        .get();
  }

  // CRUD
  Future<int> insertComment(TaskCommentsCompanion comment) => into(taskComments).insert(comment);

  Future<int> deleteComment(int id) {
    return (delete(taskComments)..where((c) => c.id.equals(id))).go();
  }
}
