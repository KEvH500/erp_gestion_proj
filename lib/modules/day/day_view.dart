import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/activity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import '../../widgets/recurrence/shift_occurrence_modal.dart';
import '../unplanned_tasks/widgets/quick_task_sheet.dart';
import '../unplanned_tasks/widgets/unplanned_task_list_widget.dart';
import 'day_controller.dart';

/// Vue détaillée d'une journée avec grille horaire et tâches imprévues
class DayView extends GetView<DayController> {
  const DayView({super.key});

  void _showAddChoicesModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Text(
                  'Ajouter pour ${controller.dayName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Option 1 : Tâche Imprévue
              InkWell(
                onTap: () {
                  Get.back();
                  QuickTaskSheet.show(context, initialDate: controller.selectedDate.value)
                      .then((_) => controller.loadDayData());
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Tâche Imprévue / Rapide',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '⚡ FLASH',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sans heure fixe. Saisissez une to-do urgente.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Option 2 : Activité Planifiée
              InkWell(
                onTap: () {
                  Get.back();
                  controller.goToAddActivity();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Activité Planifiée',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Créneau horaire avec début et fin précis.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showActivityDetails(BuildContext context, Activity activity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: activity.category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.category.label,
                      style: TextStyle(
                        color: activity.category.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    activity.timeRangeFormatted,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (activity.location != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(activity.location!),
                  ],
                ],
              ),
              if (activity.isRecurring) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded, size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Série récurrente : ${activity.recurrenceRule?.humanReadableDescription ?? "Oui"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (activity.description != null && activity.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  activity.description!,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 20),
              if (activity.isRecurring) ...[
                FilledButton.tonalIcon(
                  onPressed: () {
                    Get.back();
                    ShiftOccurrenceModal.show(
                      context: context,
                      activity: activity,
                      occurrenceDate: controller.selectedDate.value,
                      onUpdated: controller.loadDayData,
                    );
                  },
                  icon: const Icon(Icons.schedule_send_rounded),
                  label: const Text('Décaler / Déplacer cette occurrence'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.toggleActivityCompletion(activity.id);
                      },
                      icon: Icon(
                        activity.isCompleted
                            ? Icons.undo_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                      label: Text(
                        activity.isCompleted ? 'À faire' : 'Terminer',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () {
                      Get.back();
                      controller.goToEditActivity(activity);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Modifier',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () {
                      Get.back();
                      if (activity.isRecurring) {
                        Get.bottomSheet(
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Supprimer une tâche récurrente',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Voulez-vous supprimer uniquement cette occurrence ou toute la série ?',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.tonal(
                                    onPressed: () {
                                      Get.back();
                                      controller.cancelOccurrence(
                                        activity.id,
                                        controller.selectedDate.value,
                                      );
                                    },
                                    child: const Text('Cette occurrence uniquement'),
                                  ),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                    onPressed: () {
                                      Get.back();
                                      controller.deleteActivity(activity.id);
                                    },
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Toute la série'),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Annuler'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        controller.deleteActivity(activity.id);
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const totalHours = DayController.endHour - DayController.startHour + 1;
    const totalHeight = totalHours * DayController.hourHeight;

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.dayName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                controller.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Bouton direct ⚡ + Imprévu
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: () => QuickTaskSheet.show(
                context,
                initialDate: controller.selectedDate.value,
              ).then((_) => controller.loadDayData()),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.withValues(alpha: isDark ? 0.25 : 0.18),
                foregroundColor: isDark ? Colors.amber[300] : const Color(0xFFB45309),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '+ Imprévu',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  Obx(() {
                    final count = controller.pendingUnplannedCount;
                    if (count == 0) return const SizedBox.shrink();
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Rapport du jour',
            onPressed: controller.goToDailyReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Barre sélecteur rapide des 7 jours (Lundi à Dimanche)
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = index + 1;
                final dayDate = controller.getDateForDay(day);

                return Obx(() {
                  final isSelected = controller.selectedDay.value == day;
                  return _DayTabItem(
                    day: day,
                    date: dayDate,
                    isSelected: isSelected,
                    onTap: () => controller.selectDay(day),
                  );
                });
              },
            ),
          ),

          // 2. Section des tâches imprévues & Grille horaire
          Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              padding: const EdgeInsets.only(bottom: 88),
              child: Column(
                children: [
                  // Widget des tâches imprévues
                  Obx(
                    () => UnplannedTaskListWidget(
                      date: controller.selectedDate.value,
                    ),
                  ),

                  // Grille chronologique horaire
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: SizedBox(
                      height: totalHeight,
                      child: Stack(
                        children: [
                          // Lignes des heures
                          ...List.generate(totalHours, (index) {
                            final hour = DayController.startHour + index;
                            final top = index * DayController.hourHeight;

                            return Positioned(
                              top: top,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: DayController.hourHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.border.withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: DayController.timeColumnWidth,
                                      padding: const EdgeInsets.only(left: 8, top: 4),
                                      alignment: Alignment.topLeft,
                                      child: AppText.time(
                                        '${hour.toString().padLeft(2, '0')}:00',
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Blocs d'activités positionnés
                          Obx(
                            () => Stack(
                              children: controller.activities.map((activity) {
                                final startMinutes = activity.startHour * 60 + activity.startMinute;
                                final endMinutes = activity.endHour * 60 + activity.endMinute;
                                const baseMinutes = DayController.startHour * 60;

                                final top = ((startMinutes - baseMinutes) / 60.0) * DayController.hourHeight;
                                final height = ((endMinutes - startMinutes) / 60.0) * DayController.hourHeight;

                                return Positioned(
                                  top: top,
                                  left: DayController.timeColumnWidth + 4,
                                  right: 8,
                                  height: height.clamp(28.0, double.infinity),
                                  child: _ActivityTimeBlock(
                                    activity: activity,
                                    onTap: () => _showActivityDetails(context, activity),
                                    onLongPress: activity.isRecurring
                                        ? () => ShiftOccurrenceModal.show(
                                              context: context,
                                              activity: activity,
                                              occurrenceDate: controller.selectedDate.value,
                                              onUpdated: controller.loadDayData,
                                            )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Repère visuel doré marquant l'heure actuelle ("Cadran de précision")
                          Obx(() {
                            if (!controller.isSelectedDateToday) return const SizedBox.shrink();
                            final currentMin = controller.currentMinuteOfDay.value;
                            const baseMin = DayController.startHour * 60;
                            const maxMin = (DayController.endHour + 1) * 60;
                            if (currentMin < baseMin || currentMin > maxMin) {
                              return const SizedBox.shrink();
                            }
                            final top = ((currentMin - baseMin) / 60.0) * DayController.hourHeight;

                            return Positioned(
                              top: top - 4,
                              left: DayController.timeColumnWidth - 4,
                              right: 0,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentPrimary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x66E8A33D),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: AppColors.accentPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Bouton Flottant Ajouter
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChoicesModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Onglet du jour dans la barre supérieure
class _DayTabItem extends StatelessWidget {
  final int day;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayTabItem({
    required this.day,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  String get _shortDayName {
    switch (day) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mer';
      case 4:
        return 'Jeu';
      case 5:
        return 'Ven';
      case 6:
        return 'Sam';
      case 7:
        return 'Dim';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentPrimary
                : (isToday
                    ? AppColors.surfaceVariant
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isToday && !isSelected
                ? Border.all(color: AppColors.accentPrimary, width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.label(
                '$_shortDayName ${date.day}',
                fontSize: 12,
                color: isSelected
                    ? AppColors.background
                    : (isToday
                        ? AppColors.accentPrimary
                        : AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloc visuel représentant une activité dans la grille horaire
class _ActivityTimeBlock extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ActivityTimeBlock({
    required this.activity,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(
              color: activity.category.color,
              width: 3.5,
            ),
            top: const BorderSide(color: AppColors.border, width: 0.5),
            right: const BorderSide(color: AppColors.border, width: 0.5),
            bottom: const BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText.body(
                    activity.title,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                    color: activity.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (activity.isRecurring) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.sync_rounded, size: 12, color: AppColors.accentPrimary),
                ],
                if (activity.isCompleted) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.jade),
                ],
              ],
            ),
            const SizedBox(height: 2),
            AppText.time(
              activity.timeRangeFormatted,
              fontSize: 10,
              color: activity.category.color,
            ),
          ],
        ),
      ),
    );
  }
}
