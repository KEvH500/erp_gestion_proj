import 'package:drift/drift.dart';
import '../database.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects, Tasks])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  // Streams réactifs
  Stream<List<Project>> watchAllProjects({bool includeArchived = false}) {
    final query = select(projects);
    if (!includeArchived) {
      query.where((p) => p.isArchived.equals(false));
    }
    query.orderBy([(p) => OrderingTerm.asc(p.name)]);
    return query.watch();
  }

  Stream<Project?> watchProjectById(int id) {
    return (select(projects)..where((p) => p.id.equals(id))).watchSingleOrNull();
  }

  // Requêtes ponctuelles
  Future<List<Project>> getAllProjects({bool includeArchived = false}) {
    final query = select(projects);
    if (!includeArchived) {
      query.where((p) => p.isArchived.equals(false));
    }
    query.orderBy([(p) => OrderingTerm.asc(p.name)]);
    return query.get();
  }

  Future<Project?> getProjectById(int id) {
    return (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // CRUD
  Future<int> insertProject(ProjectsCompanion project) => into(projects).insert(project);

  Future<bool> updateProject(Project project) => update(projects).replace(project);

  Future<int> setProjectArchived(int id, bool isArchived) {
    return (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(isArchived: Value(isArchived)),
    );
  }

  Future<int> deleteProject(int id) {
    return (delete(projects)..where((p) => p.id.equals(id))).go();
  }

  // Compte des tâches actives rattachées à un projet
  Stream<int> watchTaskCountForProject(int projectId) {
    final count = tasks.id.count();
    final query = selectOnly(tasks)
      ..addColumns([count])
      ..where(tasks.projectId.equals(projectId) & tasks.isArchived.equals(false));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
