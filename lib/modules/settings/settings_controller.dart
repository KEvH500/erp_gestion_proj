import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../app/controllers/base_controller.dart';

/// Contrôleur GetX pour les paramètres, le thème et la configuration SQLite de l'application
class SettingsController extends BaseController {
  static const String settingsBoxName = 'settings_box';
  static const String themeKey = 'theme_mode';

  final themeMode = ThemeMode.system.obs;

  // Données de configuration SQLite réactives
  final allDays = <Map<String, dynamic>>[].obs;
  final allReminders = <Map<String, dynamic>>[].obs;
  final isLoadingConfig = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    loadSqliteConfig();
  }

  void _loadThemeMode() {
    try {
      if (Hive.isBoxOpen(settingsBoxName)) {
        final box = Hive.box(settingsBoxName);
        final index = box.get(themeKey) as int?;
        if (index != null && index >= 0 && index < ThemeMode.values.length) {
          themeMode.value = ThemeMode.values[index];
        }
      }
    } catch (_) {
      themeMode.value = ThemeMode.system;
    }
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);

    try {
      if (Hive.isBoxOpen(settingsBoxName)) {
        final box = Hive.box(settingsBoxName);
        await box.put(themeKey, mode.index);
      }
    } catch (_) {}
  }

  /// Chargement des configurations depuis SQLite
  Future<void> loadSqliteConfig() async {
    isLoadingConfig.value = true;
    try {
      final days = await configRepo.getAllDays();
      allDays.assignAll(days);

      final reminders = await configRepo.getAllReminderOptions();
      allReminders.assignAll(reminders);
    } finally {
      isLoadingConfig.value = false;
    }
  }

  /// Mettre à jour un jour dans SQLite
  Future<void> updateDay(int value, String label, bool isActive) async {
    await configRepo.updateDay(value, label, isActive);
    await loadSqliteConfig();
    Get.snackbar(
      'Jour mis à jour',
      'Le jour "$label" a été enregistré dans SQLite.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Ajouter une option de rappel personnalisée dans SQLite
  Future<void> addReminder(int minutes, String label) async {
    if (minutes <= 0) {
      Get.snackbar('Erreur', 'La durée doit être supérieure à 0 minute.');
      return;
    }
    await configRepo.addReminderOption(minutes, label);
    await loadSqliteConfig();
    Get.snackbar(
      'Rappel ajouté',
      'Le preset "$label" ($minutes min) a été ajouté dans SQLite.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Supprimer une option de rappel personnalisée de SQLite
  Future<void> deleteReminder(int minutes) async {
    await configRepo.deleteReminderOption(minutes);
    await loadSqliteConfig();
    Get.snackbar(
      'Rappel supprimé',
      'Option de rappel supprimée de SQLite.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Réinitialiser les données SQLite aux valeurs par défaut
  Future<void> resetSqliteDefaults() async {
    await configRepo.resetToDefaults();
    await loadSqliteConfig();
    Get.snackbar(
      'Configuration réinitialisée',
      'Les jours et rappels SQLite ont été restaurés aux valeurs d\'usine.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
