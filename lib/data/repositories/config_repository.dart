import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

abstract class IConfigRepository {
  Future<List<Map<String, dynamic>>> getActiveDays();
  Future<List<Map<String, dynamic>>> getAllDays();
  Future<void> updateDay(int value, String label, bool isActive);
  Future<List<Map<String, dynamic>>> getActiveReminderOptions();
  Future<List<Map<String, dynamic>>> getAllReminderOptions();
  Future<void> addReminderOption(int minutes, String label);
  Future<void> updateReminderOption(int minutes, String label, bool isActive);
  Future<void> deleteReminderOption(int minutes);
  Future<void> resetToDefaults();
}

class ConfigRepository implements IConfigRepository {
  final DatabaseService _dbService;

  ConfigRepository([DatabaseService? dbService])
      : _dbService = dbService ?? DatabaseService();

  @override
  Future<List<Map<String, dynamic>>> getActiveDays() async {
    final db = await _dbService.database;
    final results = await db.query(
      'app_days',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'order_index ASC',
    );
    return results;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllDays() async {
    final db = await _dbService.database;
    return await db.query('app_days', orderBy: 'order_index ASC');
  }

  @override
  Future<void> updateDay(int value, String label, bool isActive) async {
    final db = await _dbService.database;
    await db.update(
      'app_days',
      {
        'label': label,
        'is_active': isActive ? 1 : 0,
      },
      where: 'value = ?',
      whereArgs: [value],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveReminderOptions() async {
    final db = await _dbService.database;
    final results = await db.query(
      'reminder_options',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'minutes ASC',
    );
    // Convertit les -1 en null pour les minutes dans l'application
    return results.map((r) {
      final m = r['minutes'] as int;
      return {
        'value': m == -1 ? null : m,
        'label': r['label'] as String,
        'is_default': r['is_default'] as int,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllReminderOptions() async {
    final db = await _dbService.database;
    final results = await db.query('reminder_options', orderBy: 'minutes ASC');
    return results.map((r) {
      final m = r['minutes'] as int;
      return {
        'value': m == -1 ? null : m,
        'minutes_raw': m,
        'label': r['label'] as String,
        'is_active': (r['is_active'] as int) == 1,
        'is_default': (r['is_default'] as int) == 1,
      };
    }).toList();
  }

  @override
  Future<void> addReminderOption(int minutes, String label) async {
    final db = await _dbService.database;
    await db.insert(
      'reminder_options',
      {
        'minutes': minutes,
        'label': label,
        'is_active': 1,
        'is_default': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateReminderOption(int minutes, String label, bool isActive) async {
    final db = await _dbService.database;
    await db.update(
      'reminder_options',
      {
        'label': label,
        'is_active': isActive ? 1 : 0,
      },
      where: 'minutes = ?',
      whereArgs: [minutes],
    );
  }

  @override
  Future<void> deleteReminderOption(int minutes) async {
    final db = await _dbService.database;
    await db.delete(
      'reminder_options',
      where: 'minutes = ? AND is_default = 0',
      whereArgs: [minutes],
    );
  }

  @override
  Future<void> resetToDefaults() async {
    await _dbService.resetToDefaults();
  }
}
