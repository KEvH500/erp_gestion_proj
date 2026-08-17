import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/activity.dart';
import '../models/unplanned_task.dart';

class SyncService extends GetxService {
  static SyncService get to => Get.find();
  
  late final Box<bool> _syncStateBox;
  final GetConnect _client = GetConnect()..timeout = const Duration(seconds: 10);
  
  // URL de l'émulateur local pour les tests de développement (10.0.2.2 pour Android)
  final String _emulatorUrl = 'http://10.0.2.2:9399';
  
  // Activer l'émulateur local
  final RxBool useEmulator = true.obs;

  Future<SyncService> init() async {
    _syncStateBox = await Hive.openBox<bool>('sync_states');
    return this;
  }

  /// Détermine si un élément a déjà été synchronisé
  bool isSynced(String id) {
    return _syncStateBox.get(id, defaultValue: false) ?? false;
  }

  /// Marque un élément comme synchronisé ou non
  Future<void> setSynced(String id, bool synced) async {
    await _syncStateBox.put(id, synced);
  }

  /// Récupère l'URL d'exécution des mutations GraphQL de Data Connect
  String _getEndpointUrl(String projectId) {
    if (useEmulator.value) {
      return '$_emulatorUrl/v1/projects/$projectId/locations/us-central1/services/weekora_db/connectors/weekora_connector:executeMutation';
    } else {
      return 'https://us-central1-firebasedataconnect.googleapis.com/v1/projects/$projectId/locations/us-central1/services/weekora_db/connectors/weekora_connector:executeMutation';
    }
  }

  /// Envoie une mutation GraphQL vers Firebase Data Connect
  Future<bool> _executeMutation(String query, Map<String, dynamic> variables) async {
    try {
      final projectId = Firebase.app().options.projectId;
      final url = _getEndpointUrl(projectId);
      
      final headers = {
        'Content-Type': 'application/json',
        if (!useEmulator.value) 'x-goog-api-key': Firebase.app().options.apiKey,
      };

      final response = await _client.post(
        url,
        jsonEncode({
          'query': query,
          'variables': variables,
        }),
        headers: headers,
      );

      if (response.status.isOk) {
        final body = response.body;
        if (body != null && body['errors'] == null) {
          return true;
        } else {
          debugPrint('GraphQL Errors: ${body?['errors']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode} - ${response.statusText}');
      }
    } catch (e) {
      debugPrint('Sync execution error: $e');
    }
    return false;
  }

  /// Synchronise toutes les activités non synchronisées vers le Cloud SQL
  Future<void> syncActivities(List<Activity> activities) async {
    const String query = r'''
      mutation upsertActivity(
        $id: String!,
        $title: String!,
        $description: String,
        $startDate: String!,
        $startHour: Int!,
        $startMinute: Int!,
        $endHour: Int!,
        $endMinute: Int!,
        $category: String!,
        $isCompleted: Boolean!,
        $isLocked: Boolean!
      ) {
        activity_upsert(data: {
          id: $id,
          title: $title,
          description: $description,
          startDate: $startDate,
          startHour: $startHour,
          startMinute: $startMinute,
          endHour: $endHour,
          endMinute: $endMinute,
          category: $category,
          isCompleted: $isCompleted,
          isLocked: $isLocked
        })
      }
    ''';

    for (final act in activities) {
      if (isSynced(act.id)) continue;

      final variables = {
        'id': act.id,
        'title': act.title,
        'description': act.description ?? '',
        'startDate': act.startDate.toIso8601String().split('T')[0],
        'startHour': act.startHour,
        'startMinute': act.startMinute,
        'endHour': act.endHour,
        'endMinute': act.endMinute,
        'category': act.category.name,
        'isCompleted': act.isCompleted,
        'isLocked': act.isLocked,
      };

      final success = await _executeMutation(query, variables);
      if (success) {
        await setSynced(act.id, true);
        debugPrint('Activité répliquée avec succès : ${act.title}');
      }
    }
  }

  /// Synchronise toutes les tâches imprévues non synchronisées vers le Cloud SQL
  Future<void> syncUnplannedTasks(List<UnplannedTask> tasks) async {
    const String query = r'''
      mutation upsertUnplannedTask(
        $id: String!,
        $title: String!,
        $description: String,
        $priority: String!,
        $isCompleted: Boolean!,
        $date: String!,
        $estimatedMinutes: Int,
        $createdAt: String
      ) {
        unplannedTask_upsert(data: {
          id: $id,
          title: $title,
          description: $description,
          priority: $priority,
          isCompleted: $isCompleted,
          date: $date,
          estimatedMinutes: $estimatedMinutes,
          createdAt: $createdAt
        })
      }
    ''';

    for (final task in tasks) {
      if (isSynced(task.id)) continue;

      final variables = {
        'id': task.id,
        'title': task.title,
        'description': task.description ?? '',
        'priority': task.priority.name,
        'isCompleted': task.isCompleted,
        'date': task.date.toIso8601String().split('T')[0],
        'estimatedMinutes': task.estimatedMinutes,
        'createdAt': task.createdAt.toIso8601String(),
      };

      final success = await _executeMutation(query, variables);
      if (success) {
        await setSynced(task.id, true);
        debugPrint('Tâche imprévue répliquée avec succès : ${task.title}');
      }
    }
  }

  /// Déclenche une synchronisation globale
  Future<void> syncAll({
    required List<Activity> activities,
    required List<UnplannedTask> tasks,
  }) async {
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase n\'est pas initialisé. Synchronisation ignorée.');
      return;
    }
    await syncActivities(activities);
    await syncUnplannedTasks(tasks);
  }
}
