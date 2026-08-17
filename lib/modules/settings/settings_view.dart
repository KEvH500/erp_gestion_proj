import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../app/router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import '../../widgets/form/app_text_input_field.dart';
import 'settings_controller.dart';

/// Vue des paramètres appliquant la direction visuelle "Cadran de précision" (UI 2026)
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  void _showEditDayDialog(BuildContext context, Map<String, dynamic> day) {
    final value = day['value'] as int;
    final form = FormGroup({
      'label': FormControl<String>(
        value: day['label'] as String? ?? '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
      'isActive': FormControl<bool>(
        value: day['is_active'] == 1 || day['is_active'] == true,
      ),
    });

    Get.dialog(
      ReactiveForm(
        formGroup: form,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.edit_calendar_rounded, color: AppColors.accentPrimary),
              const SizedBox(width: 10),
              AppText.heading('Modifier ${day['label']}', fontSize: 16),
            ],
          ),
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
                    title: const AppText.body('Activer ce jour dans la semaine', fontSize: 13),
                    value: control.value ?? true,
                    activeThumbColor: AppColors.accentPrimary,
                    onChanged: (val) => control.value = val,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const AppText.label('Annuler', color: AppColors.textPrimary),
            ),
            FilledButton(
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: AppColors.background,
              ),
              child: const AppText.label('Enregistrer', color: AppColors.background),
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

    // Pré-remplissage intelligent du libellé selon les minutes
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.add_alarm_rounded, color: AppColors.accentPrimary),
              SizedBox(width: 10),
              AppText.heading('Nouveau preset de rappel', fontSize: 16),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextInputField(
                formControlName: 'minutes',
                label: 'Délai (minutes avant)',
                hint: 'Ex: 1, 15, 30, 90...',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              SizedBox(height: 12),
              AppTextInputField(
                formControlName: 'label',
                label: 'Libellé affiché',
                hint: 'Ex: 1 minute avant',
                prefixIcon: Icons.label_outline_rounded,
                isRequired: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const AppText.label('Annuler', color: AppColors.textPrimary),
            ),
            FilledButton(
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: AppColors.background,
              ),
              child: const AppText.label('Ajouter', color: AppColors.background),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.heading('Paramètres', fontSize: 18),
            AppText.caption('Configuration & Direction Visuelle 2026'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section 1 : Direction Visuelle & Thème
          _buildSectionHeader('Direction Visuelle', Icons.palette_outlined),
          const SizedBox(height: 10),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.watch_later_outlined, color: AppColors.accentPrimary, size: 20),
                    SizedBox(width: 8),
                    AppText.heading('Cadran de précision', fontSize: 15),
                  ],
                ),
                const SizedBox(height: 4),
                const AppText.body(
                  'Thème sombre anthracite chaud (#14151A), typographie éditoriale Fraunces, repères dorés et palette pierres précieuses.',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => SegmentedButton<ThemeMode>(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.accentPrimary.withValues(alpha: 0.2);
                        }
                        return AppColors.surfaceVariant;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.accentPrimary;
                        }
                        return AppColors.textSecondary;
                      }),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: AppColors.border, width: 0.8),
                      ),
                    ),
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Sombre (2026)'),
                      ),
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

          const SizedBox(height: 24),

          // Section 2 : Configuration des Jours (SQLite)
          _buildSectionHeader('Jours de la semaine (SQLite)', Icons.calendar_view_week_rounded),
          const SizedBox(height: 10),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.heading('Jours configurés', fontSize: 14),
                const SizedBox(height: 4),
                const AppText.body(
                  'Personnalisez le libellé des jours ou activez/désactivez des jours selon vos préférences.',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoadingConfig.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (controller.allDays.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: AppText.caption('Aucun jour configuré'),
                    );
                  }
                  return Column(
                    children: controller.allDays.map((day) {
                      final isActive = day['is_active'] == 1 || day['is_active'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isActive
                                  ? AppColors.accentPrimary.withValues(alpha: 0.2)
                                  : AppColors.border,
                              child: AppText.time(
                                '${day["value"]}',
                                fontSize: 10,
                                color: isActive ? AppColors.accentPrimary : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppText.body(
                                day['label'] as String? ?? '',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                              tooltip: 'Modifier',
                              onPressed: () => _showEditDayDialog(context, day),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3 : Configuration des Rappels (SQLite)
          _buildSectionHeader('Options de rappel (SQLite)', Icons.notifications_active_outlined),
          const SizedBox(height: 10),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: AppText.heading('Presets de rappels', fontSize: 14),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showAddReminderDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const AppText.label('Ajouter', fontSize: 11),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.15),
                        foregroundColor: AppColors.accentPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const AppText.body(
                  'Définissez les options de rappel proposées lors de la création d\'activité.',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.allReminders.map((rem) {
                      final isDefault = rem['is_default'] == true || rem['is_default'] == 1;
                      final minutesRaw = (rem['minutes_raw'] ?? rem['value'] ?? 0) as int;

                      return Chip(
                        label: AppText.label(
                          rem['label'] as String? ?? '$minutesRaw min',
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.surfaceVariant,
                        side: const BorderSide(color: AppColors.border, width: 0.5),
                        deleteIcon: isDefault
                            ? null
                            : const Icon(Icons.close_rounded, size: 14, color: AppColors.rubis),
                        onDeleted: isDefault ? null : () => controller.deleteReminder(minutesRaw),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: controller.resetSqliteDefaults,
                  icon: const Icon(Icons.restore_rounded, size: 16, color: AppColors.textSecondary),
                  label: const AppText.label('Restaurer configurations d\'usine', color: AppColors.textSecondary, fontSize: 12),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 4 : Fiabilité des alarmes & Arrière-plan
          _buildSectionHeader('Fiabilité des alarmes & Arrière-plan', Icons.alarm_on_rounded),
          const SizedBox(height: 10),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.heading('Précision à la minute & Mode Doze', fontSize: 14),
                const SizedBox(height: 4),
                const AppText.body(
                  'Garantit que vos rappels se déclenchent avec exactitude même lorsque l\'écran est éteint.',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                const SizedBox(height: 14),

                // 1. Alarmes Exactes
                Obx(
                  () => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      controller.exactAlarmGranted.value
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: controller.exactAlarmGranted.value ? AppColors.jade : AppColors.topaze,
                    ),
                    title: const AppText.body('Alarmes exactes (Android 12+)', fontWeight: FontWeight.bold, fontSize: 13),
                    subtitle: AppText.caption(
                      controller.exactAlarmGranted.value
                          ? 'Autorisé : Déclenchement garanti à la minute exacte.'
                          : 'Non autorisé : Vos alarmes risquent d\'être retardées.',
                      color: AppColors.textSecondary,
                    ),
                    trailing: controller.exactAlarmGranted.value
                        ? null
                        : FilledButton.tonal(
                            onPressed: controller.requestExactAlarms,
                            child: const AppText.label('Autoriser', fontSize: 11),
                          ),
                  ),
                ),
                const Divider(color: AppColors.border),

                // 2. Optimisation Batterie
                Obx(
                  () => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      controller.batteryOptimizationIgnored.value
                          ? Icons.battery_charging_full_rounded
                          : Icons.battery_alert_rounded,
                      color: controller.batteryOptimizationIgnored.value ? AppColors.jade : AppColors.topaze,
                    ),
                    title: const AppText.body('Exemption optimisation batterie', fontWeight: FontWeight.bold, fontSize: 13),
                    subtitle: AppText.caption(
                      controller.batteryOptimizationIgnored.value
                          ? 'Exemptée : Le système ne suspendra pas les alarmes.'
                          : 'Recommandé : Évite que le mode Doze n\'endorme les rappels.',
                      color: AppColors.textSecondary,
                    ),
                    trailing: controller.batteryOptimizationIgnored.value
                        ? null
                        : FilledButton.tonal(
                            onPressed: controller.requestIgnoreBatteryOptimizations,
                            child: const AppText.label('Exempter', fontSize: 11),
                          ),
                  ),
                ),
                const Divider(color: AppColors.border),

                // 3. Replanification manuelle
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sync_rounded, color: AppColors.accentPrimary),
                  title: const AppText.body('Forcer la replanification (30 jours)', fontWeight: FontWeight.bold, fontSize: 13),
                  subtitle: const AppText.caption(
                    'Recalcule toutes les alarmes des tâches récurrentes et ponctuelles immédiatement.',
                    color: AppColors.textSecondary,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.accentPrimary),
                    onPressed: controller.rescheduleAllNotificationsNow,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 5 : Export & Partage
          _buildSectionHeader('Export & Données', Icons.ios_share_rounded),
          const SizedBox(height: 10),
          _buildCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.saphir.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.file_download_outlined, color: AppColors.saphir, size: 20),
              ),
              title: const AppText.body('Export hebdomadaire (CSV)', fontWeight: FontWeight.bold, fontSize: 13),
              subtitle: const AppText.caption(
                'Prévisualiser, filtrer et exporter l\'ensemble des tâches et créneaux horaires d\'une semaine.',
                color: AppColors.textSecondary,
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () => Get.toNamed(Routes.EXPORT),
            ),
          ),

          const SizedBox(height: 24),

          // Section 6 : À propos
          _buildSectionHeader('À propos', Icons.info_outline_rounded),
          const SizedBox(height: 10),
          _buildCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 36,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const AppText.heading('Emploi du Temps', fontSize: 18),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
                  ),
                  child: const AppText.label(
                    'Cadran de précision • UI 2026',
                    fontSize: 11,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                const AppText.body(
                  'Gestion d\'emploi du temps hebdomadaire avec non-chevauchement, récurrence complète, notifications à la minute exacte et export CSV.',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 10),
                _buildInfoRow('Architecture', 'Flutter & GetX (MVC)'),
                const SizedBox(height: 6),
                _buildInfoRow('Stockage Type-Safe', 'Drift (v4) + Hive'),
                const SizedBox(height: 6),
                _buildInfoRow('Configuration Dynamique', 'SQLite (sqflite)'),
                const SizedBox(height: 6),
                _buildInfoRow('Typographie', 'Fraunces / Inter / IBM Plex Mono'),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentPrimary),
        const SizedBox(width: 8),
        AppText.label(
          title.toUpperCase(),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.accentPrimary,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.caption(label, color: AppColors.textSecondary),
        AppText.label(value, fontSize: 11, color: AppColors.textPrimary),
      ],
    );
  }
}
