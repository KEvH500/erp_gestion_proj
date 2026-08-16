import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../models/activity.dart';
import '../../models/recurrence_rule.dart';
import '../../widgets/form/app_date_picker_field.dart';
import '../../widgets/form/app_dropdown_field.dart';
import '../../widgets/form/app_text_input_field.dart';
import '../../widgets/form/app_time_picker_field.dart';
import 'activity_form_controller.dart';

/// Vue du formulaire d'ajout et édition d'activité avec reactive_forms et récurrence généralisée
class ActivityFormView extends GetView<ActivityFormController> {
  const ActivityFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReactiveForm(
      formGroup: controller.form,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              controller.isEditing.value ? "Modifier l'activité" : 'Nouvelle activité',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1 : Informations Générales
            _buildSectionHeader(context, 'Informations générales'),
            const SizedBox(height: 12),

            // Champ Titre
            const AppTextInputField(
              formControlName: 'title',
              label: 'Titre de l\'activité',
              hint: 'Ex: Algorithmique & Structures, Réunion projet...',
              prefixIcon: Icons.title_rounded,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Champ Description
            const AppTextInputField(
              formControlName: 'description',
              label: 'Description (optionnelle)',
              hint: 'Notes, devoirs à rendre, objectifs du cours...',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Champ Lieu / Salle
            const AppTextInputField(
              formControlName: 'location',
              label: 'Lieu / Salle (optionnel)',
              hint: 'Ex: Amphi A, Salle 204, Teams...',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),

            // Section 2 : Catégorie
            _buildSectionHeader(context, 'Catégorie'),
            const SizedBox(height: 12),
            ReactiveValueListenableBuilder<ActivityCategory>(
              formControlName: 'category',
              builder: (context, control, child) {
                final currentCat = control.value ?? ActivityCategory.cours;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ActivityCategory.values.map((category) {
                    final isSelected = currentCat == category;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected ? Colors.white : category.color,
                          ),
                          const SizedBox(width: 6),
                          Text(category.label),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: category.color,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          control.value = category;
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 3 : Date d'ancrage & Plage Horaire
            _buildSectionHeader(context, 'Date & Horaires'),
            const SizedBox(height: 12),

            // Date de début
            const AppDatePickerField(
              formControlName: 'startDate',
              label: 'Date de début / premier événement',
              prefixIcon: Icons.calendar_today_rounded,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Sélecteurs Heure de début et Fin
            const Row(
              children: [
                Expanded(
                  child: AppTimePickerField(
                    formControlName: 'startTime',
                    label: 'Heure de début',
                    prefixIcon: Icons.access_time_rounded,
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppTimePickerField(
                    formControlName: 'endTime',
                    label: 'Heure de fin',
                    prefixIcon: Icons.timer_off_outlined,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 4 : Répétition & Récurrence
            _buildSectionHeader(context, 'Récurrence'),
            const SizedBox(height: 12),

            // Toggle Récurrent
            ReactiveValueListenableBuilder<bool>(
              formControlName: 'isRecurring',
              builder: (context, control, child) {
                final isRec = control.value ?? false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Répéter cet événement'),
                      subtitle: Text(
                        isRec
                            ? 'L\'activité se répète selon une règle personnalisée.'
                            : 'Événement ponctuel (une seule fois à la date choisie).',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      value: isRec,
                      onChanged: (val) => control.value = val,
                    ),
                    if (isRec) ...[
                      const SizedBox(height: 16),
                      _buildRecurrenceCard(context),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 5 : Rappels & Notifications
            _buildSectionHeader(context, 'Notification de rappel'),
            const SizedBox(height: 12),

            Obx(
              () => AppDropdownField<int?>(
                formControlName: 'reminderMinutesBefore',
                label: 'Rappel avant l\'événement',
                prefixIcon: Icons.notifications_active_outlined,
                items: controller.reminderOptions.map((opt) {
                  return DropdownMenuItem<int?>(
                    value: opt['value'] as int?,
                    child: Text(opt['label'] as String),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton de Sauvegarde
            Obx(
              () => FilledButton.icon(
                onPressed: controller.isSaving.value ? null : controller.saveActivity,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  controller.isSaving.value
                      ? 'Enregistrement...'
                      : (controller.isEditing.value
                          ? 'Mettre à jour l\'activité'
                          : 'Créer l\'activité'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fréquence
          AppDropdownField<RecurrenceFrequency>(
            formControlName: 'recurrenceFrequency',
            label: 'Fréquence',
            prefixIcon: Icons.repeat_rounded,
            items: RecurrenceFrequency.values.map((freq) {
              return DropdownMenuItem<RecurrenceFrequency>(
                value: freq,
                child: Text(freq.label),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Intervalle personnalisé
          ReactiveValueListenableBuilder<RecurrenceFrequency>(
            formControlName: 'recurrenceFrequency',
            builder: (context, freqControl, child) {
              final freq = freqControl.value ?? RecurrenceFrequency.weekly;
              String unitLabel = 'semaine(s)';
              if (freq == RecurrenceFrequency.daily) unitLabel = 'jour(s)';
              if (freq == RecurrenceFrequency.monthly) unitLabel = 'mois';

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ReactiveTextField<int>(
                      formControlName: 'recurrenceInterval',
                      valueAccessor: IntValueAccessor(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Répéter tous les / toutes les',
                        prefixIcon: const Icon(Icons.numbers_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Text(
                      unitLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Sélecteur des jours de la semaine (visible si hebdomadaire)
          ReactiveValueListenableBuilder<RecurrenceFrequency>(
            formControlName: 'recurrenceFrequency',
            builder: (context, freqControl, child) {
              if (freqControl.value != RecurrenceFrequency.weekly) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jours de répétition :',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ReactiveValueListenableBuilder<List<int>>(
                    formControlName: 'recurrenceWeekDays',
                    builder: (context, control, child) {
                      final selectedDays = control.value ?? [];
                      final weekDaysMap = [
                        {'day': 1, 'label': 'L'},
                        {'day': 2, 'label': 'M'},
                        {'day': 3, 'label': 'M'},
                        {'day': 4, 'label': 'J'},
                        {'day': 5, 'label': 'V'},
                        {'day': 6, 'label': 'S'},
                        {'day': 7, 'label': 'D'},
                      ];

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: weekDaysMap.map((d) {
                          final dayNum = d['day'] as int;
                          final isSelected = selectedDays.contains(dayNum);

                          return InkWell(
                            onTap: () => controller.toggleWeekDay(dayNum),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                d['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          // Type de fin de récurrence
          AppDropdownField<RecurrenceEndType>(
            formControlName: 'recurrenceEndType',
            label: 'Fin de la récurrence',
            prefixIcon: Icons.event_busy_rounded,
            items: RecurrenceEndType.values.map((endType) {
              return DropdownMenuItem<RecurrenceEndType>(
                value: endType,
                child: Text(endType.label),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Champs conditionnels selon la fin
          ReactiveValueListenableBuilder<RecurrenceEndType>(
            formControlName: 'recurrenceEndType',
            builder: (context, endTypeControl, child) {
              final endType = endTypeControl.value ?? RecurrenceEndType.never;

              if (endType == RecurrenceEndType.untilDate) {
                return const AppDatePickerField(
                  formControlName: 'recurrenceUntilDate',
                  label: 'Date de fin',
                  prefixIcon: Icons.event_available_rounded,
                );
              } else if (endType == RecurrenceEndType.count) {
                return ReactiveTextField<int>(
                  formControlName: 'recurrenceCount',
                  valueAccessor: IntValueAccessor(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nombre d\'occurrences',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}

