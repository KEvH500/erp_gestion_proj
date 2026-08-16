import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:erp_gestion_proj/models/activity.dart';
import 'package:erp_gestion_proj/models/recurrence_rule.dart';
import 'package:erp_gestion_proj/models/recurrence_exception.dart';
import 'package:erp_gestion_proj/modules/export/export_controller.dart';
import 'package:erp_gestion_proj/data/repositories/activity_repository.dart';

class MockActivityRepository implements IActivityRepository {
  final List<Activity> activities = [];

  @override
  List<Activity> getAllActivities() => activities;

  @override
  List<Activity> getActivitiesForDate(DateTime date) => [];

  @override
  List<Activity> getActivitiesForDay(int dayOfWeek) => [];

  @override
  Future<void> addActivity(Activity activity) async => activities.add(activity);

  @override
  Future<void> updateActivity(Activity activity) async {}

  @override
  Future<void> deleteActivity(String id) async {}

  @override
  Activity? getActivityById(String id) => activities.firstWhereOrNull((a) => a.id == id);

  @override
  Future<void> toggleActivityCompletion(String id) async {}

  @override
  Future<void> clearAllActivities() async => activities.clear();

  @override
  Future<void> addRecurrenceException(String activityId, RecurrenceException exception) async {}

  @override
  Future<void> removeRecurrenceException(String activityId, DateTime originalDate) async {}

  @override
  Future<void> detachOccurrence(String activityId, DateTime originalDate, Activity detachedActivity) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockActivityRepository mockRepo;
  late ExportController controller;

  final monday = DateTime(2026, 3, 9); // Lundi 9 mars 2026

  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() {
    Get.reset();
    mockRepo = MockActivityRepository();
    Get.put<IActivityRepository>(mockRepo);
  });

  tearDown(() {
    Get.reset();
  });

  test('ExportController - Navigation entre semaines', () {
    controller = ExportController();
    controller.currentMonday.value = monday;
    controller.loadWeekData();

    expect(controller.currentMonday.value, equals(monday));
    expect(controller.daysOfWeek.length, equals(7));

    controller.nextWeek();
    expect(controller.currentMonday.value, equals(DateTime(2026, 3, 16)));

    controller.previousWeek();
    expect(controller.currentMonday.value, equals(monday));
  });

  test('ExportController - Génération CSV avec tâches récurrentes et ponctuelles', () {
    mockRepo.activities.addAll([
      Activity(
        id: 'act-1',
        title: 'Mathématiques',
        startDate: monday,
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        category: ActivityCategory.cours,
        isLocked: false,
      ),
      Activity(
        id: 'act-2',
        title: 'Réunion Projet',
        startDate: monday.add(const Duration(days: 2)), // Mercredi 11 mars
        startHour: 14,
        startMinute: 0,
        endHour: 15,
        endMinute: 30,
        category: ActivityCategory.travail,
        isLocked: true,
      ),
    ]);

    controller = ExportController();
    controller.currentMonday.value = monday;
    controller.loadWeekData();

    final csv = controller.generateCsvContent();

    expect(csv.contains('Jour,Date,Heure Debut,Heure Fin,Titre,Categorie,Lieu,Verrouille,Recurrent'), isTrue);
    expect(csv.contains('Mathématiques'), isTrue);
    expect(csv.contains('08:00'), isTrue);
    expect(csv.contains('10:00'), isTrue);
    expect(csv.contains('Réunion Projet'), isTrue);
    expect(csv.contains('14:00'), isTrue);
    expect(csv.contains('Oui'), isTrue); // isLocked = true
  });

  test('ExportController - Tâche récurrente avec exception décalée dans la semaine', () {
    final recurringTask = Activity(
      id: 'rec-1',
      title: 'Anglais',
      startDate: DateTime(2026, 3, 2), // Lundi d'avant
      startHour: 10,
      startMinute: 0,
      endHour: 12,
      endMinute: 0,
      category: ActivityCategory.cours,
      recurrenceRule: RecurrenceRule(
        id: 'rule-anglais',
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
      ),
      exceptions: [
        // Décalé du Lundi 9 mars au Mardi 10 mars de 14h à 16h
        RecurrenceException(
          taskId: 'rec-1',
          originalDate: monday,
          newDate: DateTime(2026, 3, 10),
          newStartHour: 14,
          newStartMinute: 0,
          newEndHour: 16,
          newEndMinute: 0,
        ),
      ],
    );

    mockRepo.activities.add(recurringTask);

    controller = ExportController();
    controller.currentMonday.value = monday;
    controller.loadWeekData();

    final tuesday = DateTime(2026, 3, 10);
    final tuesdayActivities = controller.weekActivitiesMap[tuesday] ?? [];

    expect(tuesdayActivities.length, equals(1));
    expect(tuesdayActivities.first.title, equals('Anglais'));
    expect(tuesdayActivities.first.startHour, equals(14));
    expect(tuesdayActivities.first.endHour, equals(16));

    // Lundi 9 mars ne doit plus avoir cette occurrence
    final mondayActivities = controller.weekActivitiesMap[monday] ?? [];
    expect(mondayActivities, isEmpty);
  });
}
