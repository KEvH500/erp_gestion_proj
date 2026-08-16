import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:erp_gestion_proj/data/services/database_service.dart';
import 'package:erp_gestion_proj/data/repositories/config_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SQLite ConfigRepository tests', () {
    test('Initial seeding and get active days', () async {
      final repo = ConfigRepository(DatabaseService());
      await repo.resetToDefaults();

      final days = await repo.getActiveDays();
      expect(days.length, 7);
      expect(days[0]['label'], 'Lundi');
      expect(days[6]['label'], 'Dimanche');
    });

    test('Initial seeding and get active reminders', () async {
      final repo = ConfigRepository(DatabaseService());
      final reminders = await repo.getActiveReminderOptions();
      expect(reminders.isNotEmpty, true);
      expect(reminders.any((r) => r['label'] == 'Aucun rappel'), true);
      expect(reminders.any((r) => r['label'] == '5 minutes avant'), true);
    });

    test('Add and delete custom reminder option', () async {
      final repo = ConfigRepository(DatabaseService());
      await repo.addReminderOption(45, '45 minutes avant');

      var allReminders = await repo.getAllReminderOptions();
      expect(allReminders.any((r) => r['label'] == '45 minutes avant'), true);

      await repo.deleteReminderOption(45);
      allReminders = await repo.getAllReminderOptions();
      expect(allReminders.any((r) => r['label'] == '45 minutes avant'), false);
    });
  });
}
