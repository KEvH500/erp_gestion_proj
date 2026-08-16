import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../app/router/app_router.dart';
import '../../widgets/form/app_text_input_field.dart';
import 'settings_controller.dart';

/// Vue des paramètres avec gestion du thème et configuration dynamique SQLite
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  void _showEditDayDialog(BuildContext context, Map<String, dynamic> day) {
    final value = day['value'] as int;
    final form = FormGroup({
      'label': FormControl<String>(
        value: day['label'] as String,
        validators: [Validators.required, Validators.minLength(1)],
      ),
      'isActive': FormControl<bool>(
        value: (day['is_active'] as int) == 1,
      ),
    });

    Get.dialog(
      ReactiveForm(
        formGroup: form,
        child: AlertDialog(
          title: Text('Modifier ${day['label']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppTextInputField(
                formControlName: 'label',
                label: 'Nom du jour',
                prefixIcon: Icons.edit_calendar_rounded,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'isActive',
                builder: (context, control, child) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activer ce jour'),
                    value: control.value ?? true,
                    onChanged: (val) => control.value = val,
                  );
                },
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
                if (form.valid) {
                  final newLabel = (form.control('label').value as String).trim();
                  final isActive = (form.control('isActive').value as bool?) ?? true;
                  Get.back();
                  controller.updateDay(value, newLabel, isActive);
                } else {
                  form.markAllAsTouched();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final form = FormGroup({
      'minutes': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.number(), Validators.min(1)],
      ),
      'label': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
    });

    // Écouter les changements de minutes pour pré-remplir intelligemment le libellé
    form.control('minutes').valueChanges.listen((val) {
      final m = int.tryParse((val as String?)?.trim() ?? '');
      final currentLabel = form.control('label').value as String? ?? '';
      if (m != null && currentLabel.isEmpty) {
        if (m < 60) {
          form.control('label').value = '$m minutes avant';
        } else {
          final h = m ~/ 60;
          final rem = m % 60;
          form.control('label').value =
              rem == 0 ? '$h heure${h > 1 ? "s" : ""} avant' : '$h h $rem min avant';
        }
      }
    });

    Get.dialog(
      ReactiveForm(
        formGroup: form,
        child: AlertDialog(
          title: const Text('Ajouter un rappel (SQLite)'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextInputField(
                formControlName: 'minutes',
                label: 'Minutes avant',
                hint: 'Ex: 20, 45, 90...',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              SizedBox(height: 12),
              AppTextInputField(
                formControlName: 'label',
                label: 'Libellé affiché',
                hint: 'Ex: 20 minutes avant',
                prefixIcon: Icons.label_outline_rounded,
                isRequired: true,
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
                if (form.valid) {
                  final m = int.tryParse((form.control('minutes').value as String).trim());
                  final label = (form.control('label').value as String).trim();
                  if (m != null && m > 0 && label.isNotEmpty) {
                    Get.back();
                    controller.addReminder(m, label);
                  }
                } else {
                  form.markAllAsTouched();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
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
          _buildSectionHeader(
              context, 'Jours de la semaine (SQLite)', Icons.calendar_view_week_rounded),
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
          _buildSectionHeader(
              context, 'Options de rappel (SQLite)', Icons.notifications_active_outlined),
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
                          backgroundColor:
                              isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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
                    label: const Text('Restaurer configurations d\'usine',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section 4 : Fiabilité des alarmes & Arrière-plan
          _buildSectionHeader(
              context, 'Fiabilité des alarmes & Arrière-plan', Icons.alarm_on_rounded),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Précision à la minute exacte & Mode Veille (Doze)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sur Android 12+, des autorisations spécifiques garantissent que vos alarmes sonnent précisément à l\'heure même lorsque l\'écran est éteint.',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  // 1. Statut Alarme Exacte (SCHEDULE_EXACT_ALARM)
                  Obx(
                    () => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        controller.exactAlarmGranted.value
                            ? Icons.check_circle_rounded
                            : Icons.warning_amber_rounded,
                        color: controller.exactAlarmGranted.value
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: const Text(
                        'Alarmes exactes (Android 12+)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      subtitle: Text(
                        controller.exactAlarmGranted.value
                            ? 'Autorisé : Déclenchement garanti à la minute exacte.'
                            : 'Non autorisé : Vos alarmes risquent d\'être retardées.',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: controller.exactAlarmGranted.value
                          ? null
                          : FilledButton.tonal(
                              onPressed: controller.requestExactAlarms,
                              child: const Text('Autoriser', style: TextStyle(fontSize: 11)),
                            ),
                    ),
                  ),
                  const Divider(),

                  // 2. Statut Optimisation de Batterie
                  Obx(
                    () => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        controller.batteryOptimizationIgnored.value
                            ? Icons.battery_charging_full_rounded
                            : Icons.battery_alert_rounded,
                        color: controller.batteryOptimizationIgnored.value
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: const Text(
                        'Exemption d\'optimisation batterie',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      subtitle: Text(
                        controller.batteryOptimizationIgnored.value
                            ? 'Exemptée : Le système ne suspendra pas les alarmes.'
                            : 'Recommandé : Évite que le mode Doze n\'endorme les rappels.',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: controller.batteryOptimizationIgnored.value
                          ? null
                          : FilledButton.tonal(
                              onPressed: controller.requestIgnoreBatteryOptimizations,
                              child: const Text('Exempter', style: TextStyle(fontSize: 11)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Bouton Replanification manuelle de la fenêtre glissante
                  OutlinedButton.icon(
                    onPressed: controller.rescheduleAllNotificationsNow,
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text(
                      'Replanifier la fenêtre glissante (30 jours)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section 5 : Export & Partage
          _buildSectionHeader(context, 'Export & Données', Icons.ios_share_rounded),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined, color: Colors.blueAccent),
              title: const Text('Export hebdomadaire (CSV)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Prévisualiser et exporter les tâches et horaires de n\'importe quelle semaine.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Get.toNamed(Routes.EXPORT),
            ),
          ),

          const SizedBox(height: 28),

          // Section 6 : À propos
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
                      Text('Architecture',
                          style: TextStyle(
                              fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Text('Flutter & GetX (MVC)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stockage Données',
                          style: TextStyle(
                              fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Text('Drift & SQLite (Type-Safe)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Formulaires',
                          style: TextStyle(
                              fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const Text('reactive_forms (FormGroup)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
