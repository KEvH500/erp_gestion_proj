import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

/// Vue des paramètres avec gestion du thème et configuration dynamique SQLite
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  void _showEditDayDialog(BuildContext context, Map<String, dynamic> day) {
    final value = day['value'] as int;
    final labelCtrl = TextEditingController(text: day['label'] as String);
    final isActive = ((day['is_active'] as int) == 1).obs;

    Get.dialog(
      AlertDialog(
        title: Text('Modifier ${day['label']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom du jour',
                prefixIcon: Icon(Icons.edit_calendar_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activer ce jour'),
                value: isActive.value,
                onChanged: (val) => isActive.value = val,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newLabel = labelCtrl.text.trim();
              if (newLabel.isNotEmpty) {
                Get.back();
                controller.updateDay(value, newLabel, isActive.value);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final minCtrl = TextEditingController();
    final labelCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter un rappel (SQLite)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutes avant *',
                hintText: 'Ex: 20, 45, 90...',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              onChanged: (val) {
                final m = int.tryParse(val.trim());
                if (m != null && labelCtrl.text.isEmpty) {
                  if (m < 60) {
                    labelCtrl.text = '$m minutes avant';
                  } else {
                    final h = m ~/ 60;
                    final rem = m % 60;
                    labelCtrl.text = rem == 0
                        ? '$h heure${h > 1 ? "s" : ""} avant'
                        : '$h h $rem min avant';
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Libellé affiché *',
                hintText: 'Ex: 20 minutes avant',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final m = int.tryParse(minCtrl.text.trim());
              final label = labelCtrl.text.trim();
              if (m != null && m > 0 && label.isNotEmpty) {
                Get.back();
                controller.addReminder(m, label);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section 1 : Apparence & Thème
          _buildSectionHeader(context, 'Apparence', Icons.palette_outlined),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mode d\'affichage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choisissez entre le thème clair, sombre ou l\'adaptation automatique.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_rounded),
                          label: Text('Système'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text('Clair'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text('Sombre'),
                        ),
                      ],
                      selected: {controller.themeMode.value},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        controller.changeThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section 2 : Configuration des Jours (SQLite)
          _buildSectionHeader(context, 'Jours de la semaine (SQLite)', Icons.calendar_view_week_rounded),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jours configurés',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personnalisez le libellé des jours ou activez/désactivez des jours selon vos préférences.',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => controller.allDays.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: controller.allDays.map((day) {
                              final isActive = (day['is_active'] as int) == 1;
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isActive
                                      ? theme.colorScheme.primaryContainer
                                      : (isDark ? Colors.grey[800] : Colors.grey[300]),
                                  child: Text(
                                    '${day["value"]}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? theme.colorScheme.primary : Colors.grey,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  day['label'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: isActive ? null : TextDecoration.lineThrough,
                                    color: isActive ? null : Colors.grey,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Modifier',
                                  onPressed: () => _showEditDayDialog(context, day),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section 3 : Configuration des Rappels (SQLite)
          _buildSectionHeader(context, 'Options de rappel (SQLite)', Icons.notifications_active_outlined),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Presets de rappels',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _showAddReminderDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Définissez les options de rappel proposées lors de la création d\'activité.',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.allReminders.map((rem) {
                        final isDefault = rem['is_default'] as bool;
                        final minutesRaw = rem['minutes_raw'] as int;

                        return Chip(
                          label: Text(rem['label'] as String, style: const TextStyle(fontSize: 12)),
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          deleteIcon: isDefault ? null : const Icon(Icons.close_rounded, size: 16),
                          onDeleted: isDefault ? null : () => controller.deleteReminder(minutesRaw),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: controller.resetSqliteDefaults,
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: const Text('Restaurer configurations d\'usine', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section 4 : À propos
          _buildSectionHeader(context, 'À propos', Icons.info_outline_rounded),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Emploi du Temps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Votre compagnon quotidien pour structurer vos journées du lundi au dimanche, optimiser votre temps et rester ordonné en toute sérénité.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Architecture', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Text('Flutter & GetX (MVC)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Configuration', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Text('SQLite (Sqflite)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stockage Activités', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Text('Hive (100% hors-ligne)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
