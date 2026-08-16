import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/activity.dart';
import 'activity_form_controller.dart';

/// Vue du formulaire d'ajout et édition d'activité
class ActivityFormView extends GetView<ActivityFormController> {
  const ActivityFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditing.value
                ? "Modifier l'activité"
                : 'Nouvelle activité',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1 : Informations Générales
            _buildSectionHeader(context, 'Informations générales'),
            const SizedBox(height: 12),

            // Champ Titre
            TextFormField(
              controller: controller.titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'activité *',
                hintText: 'Ex: Algorithmique & Structures, Réunion projet...',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre de l\'activité est obligatoire.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Champ Description
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                hintText: 'Notes, devoirs à rendre, objectifs du cours...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Champ Lieu / Salle
            TextFormField(
              controller: controller.locationController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Lieu / Salle (optionnel)',
                hintText: 'Ex: Amphi A, Salle 204, Teams...',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2 : Catégorie
            _buildSectionHeader(context, 'Catégorie'),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActivityCategory.values.map((category) {
                  final isSelected = controller.selectedCategory.value == category;
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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        controller.selectedCategory.value = category;
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Section 3 : Plage Horaire & Jour
            _buildSectionHeader(context, 'Horaire & Jour'),
            const SizedBox(height: 12),

            // Sélecteur du jour de la semaine
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedDayOfWeek.value,
                decoration: const InputDecoration(
                  labelText: 'Jour de la semaine *',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                items: controller.days.map((day) {
                  return DropdownMenuItem<int>(
                    value: day['value'] as int,
                    child: Text(day['label'] as String),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedDayOfWeek.value = val;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Sélecteurs Heure de début et Fin
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: controller.startTime.value,
                        );
                        if (picked != null) {
                          controller.setStartTime(picked);
                        }
                      },
                      icon: const Icon(Icons.access_time_rounded),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Début', style: TextStyle(fontSize: 11)),
                          Text(
                            controller.formatTimeOfDay(controller.startTime.value),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: controller.endTime.value,
                        );
                        if (picked != null) {
                          controller.setEndTime(picked);
                        }
                      },
                      icon: const Icon(Icons.timer_off_outlined),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fin', style: TextStyle(fontSize: 11)),
                          Text(
                            controller.formatTimeOfDay(controller.endTime.value),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
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
              () => DropdownButtonFormField<int?>(
                initialValue: controller.selectedReminderMinutes.value,
                decoration: const InputDecoration(
                  labelText: 'Notification de rappel',
                  prefixIcon: Icon(Icons.notifications_active_outlined),
                ),
                items: controller.reminderOptions.map((opt) {
                  return DropdownMenuItem<int?>(
                    value: opt['value'] as int?,
                    child: Text(opt['label'] as String),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedReminderMinutes.value = val;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Option Récurrent chaque semaine
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Répéter chaque semaine'),
                subtitle: Text(
                  controller.isRecurring.value
                      ? 'L\'activité se reproduit chaque semaine.'
                      : 'Activité ponctuelle pour cette semaine.',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
                value: controller.isRecurring.value,
                onChanged: (val) => controller.isRecurring.value = val,
              ),
            ),
            const SizedBox(height: 32),

            // Bouton de Sauvegarde
            Obx(
              () => FilledButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.saveActivity,
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
