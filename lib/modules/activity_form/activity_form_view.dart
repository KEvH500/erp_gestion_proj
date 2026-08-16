import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../models/activity.dart';
import '../../widgets/form/app_dropdown_field.dart';
import '../../widgets/form/app_text_input_field.dart';
import '../../widgets/form/app_time_picker_field.dart';
import 'activity_form_controller.dart';

/// Vue du formulaire d'ajout et édition d'activité avec reactive_forms
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

            // Section 3 : Plage Horaire & Jour
            _buildSectionHeader(context, 'Horaire & Jour'),
            const SizedBox(height: 12),

            // Sélecteur du jour de la semaine
            Obx(
              () => AppDropdownField<int>(
                formControlName: 'dayOfWeek',
                label: 'Jour de la semaine',
                prefixIcon: Icons.calendar_today_rounded,
                isRequired: true,
                items: controller.days.map((day) {
                  return DropdownMenuItem<int>(
                    value: day['value'] as int,
                    child: Text(day['label'] as String),
                  );
                }).toList(),
              ),
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

            // Section 4 : Options & Rappel
            _buildSectionHeader(context, 'Options & Rappel'),
            const SizedBox(height: 12),

            // Sélecteur de rappel
            Obx(
              () => AppDropdownField<int?>(
                formControlName: 'reminderMinutesBefore',
                label: 'Notification de rappel',
                prefixIcon: Icons.notifications_active_outlined,
                items: controller.reminderOptions.map((opt) {
                  return DropdownMenuItem<int?>(
                    value: opt['value'] as int?,
                    child: Text(opt['label'] as String),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Option Récurrent chaque semaine
            ReactiveValueListenableBuilder<bool>(
              formControlName: 'isRecurring',
              builder: (context, control, child) {
                final isRec = control.value ?? true;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Répéter chaque semaine'),
                  subtitle: Text(
                    isRec
                        ? 'L\'activité se reproduit chaque semaine.'
                        : 'Activité ponctuelle pour cette semaine.',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  value: isRec,
                  onChanged: (val) => control.value = val,
                );
              },
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
