import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/router/app_router.dart';
import '../../models/activity.dart';
import '../../models/unplanned_task.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import '../../widgets/recurrence/shift_occurrence_modal.dart';
import '../unplanned_tasks/widgets/quick_task_sheet.dart';
import 'week_controller.dart';

/// Vue hebdomadaire affichant les 7 jours de la semaine (Lundi à Dimanche)
class WeekView extends GetView<WeekController> {
  const WeekView({super.key});

  void _showAddChoicesModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AppText.heading(
                'Que souhaitez-vous ajouter ?',
                fontSize: 18,
              ),
              const SizedBox(height: 16),
              // Option 1 : Tâche Imprévue / Rapide (⚡ FLASH)
              InkWell(
                onTap: () {
                  Get.back();
                  QuickTaskSheet.show(context).then((_) => controller.loadData());
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.topaze.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.topaze.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.topaze,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppText.heading(
                                  'Tâche Imprévue / Rapide',
                                  fontSize: 15,
                                ),
                                SizedBox(width: 6),
                                AppText.label(
                                  '⚡ FLASH',
                                  color: AppColors.topaze,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            AppText.body(
                              'Sans contrainte d\'horaire fixe. Créez un to-do urgent en 2 secondes.',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Option 2 : Activité / Événement planifié (🕒 HORAIRE)
              InkWell(
                onTap: () {
                  Get.back();
                  controller.goToAddActivity();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.saphir.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.saphir.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          color: AppColors.saphir,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppText.heading(
                                  'Activité / Événement',
                                  fontSize: 15,
                                ),
                                SizedBox(width: 6),
                                AppText.label(
                                  '🕒 HORAIRE',
                                  color: AppColors.saphir,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            AppText.body(
                              'Cours, travail, réunion ou sport avec horaires de début et de fin.',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekora',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            Obx(
              () => Text(
                controller.monthYearFormatted,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Bouton d'action directe "⚡ + Imprévu"
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilledButton.tonalIcon(
              onPressed: () => QuickTaskSheet.show(context).then((_) => controller.loadData()),
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
                    final count = controller.todayUnplannedPendingCount;
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
            tooltip: 'Rapport de journée',
            onPressed: controller.goToDailyReport,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export hebdomadaire',
            onPressed: () => Get.toNamed(Routes.EXPORT),
          ),
          Obx(() {
            if (controller.weekOffset.value == 0) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: controller.resetToCurrentWeek,
              icon: const Icon(Icons.today_rounded, size: 18),
              label: const Text(
                'Aujourd\'hui',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Paramètres',
            onPressed: controller.goToSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Barre de navigation de semaine (Précédent / Suivant)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                  tooltip: 'Semaine précédente',
                  onPressed: controller.previousWeek,
                ),
                Obx(
                  () => Column(
                    children: [
                      AppText.heading(
                        'Semaine du ${controller.startFormatted} au ${controller.endFormatted}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 2),
                      AppText.label(
                        controller.weekSubtitle,
                        fontSize: 11,
                        color: AppColors.accentPrimary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                  tooltip: 'Semaine suivante',
                  onPressed: controller.nextWeek,
                ),
              ],
            ),
          ),

          // 2. Liste verticale des 7 jours (Lundi à Dimanche)
          Expanded(
            child: Obx(
              () {
                // Access reactive variables here to register them with Obx
                controller.weekOffset.value;
                controller.activitiesByDay.keys;
                controller.allUnplannedTasks.length;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 88),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dayOfWeek = index + 1; // 1 = Lundi ... 7 = Dimanche
                    final dayDate = controller.getDateForDay(dayOfWeek);
                    final isCurrentDay = controller.isToday(dayDate);
                    final activities = controller.getActivitiesForDay(dayOfWeek);
                    final unplannedTasks = controller.getUnplannedTasksForDate(dayDate);

                    return _DayCard(
                      dayOfWeek: dayOfWeek,
                      dayDate: dayDate,
                      isToday: isCurrentDay,
                      activities: activities,
                      unplannedTasks: unplannedTasks,
                      onTap: () => controller.goToDay(dayOfWeek, dayDate),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 3. Bouton Flottant avec double action / modal de choix
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChoicesModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // 4. Bottom Navigation Bar pour accès rapide
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.bottomNavIndex.value,
          onDestinationSelected: controller.onBottomNavSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_view_week_outlined),
              selectedIcon: Icon(Icons.calendar_view_week_rounded),
              label: 'Semaine',
            ),
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today_rounded),
              label: 'Aujourd\'hui',
            ),
            NavigationDestination(
              icon: Icon(Icons.track_changes_outlined),
              selectedIcon: Icon(Icons.track_changes_rounded),
              label: 'Objectifs',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Réglages',
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte représentant un jour de la semaine
class _DayCard extends StatelessWidget {
  final int dayOfWeek;
  final DateTime dayDate;
  final bool isToday;
  final List<Activity> activities;
  final List<UnplannedTask> unplannedTasks;
  final VoidCallback onTap;

  const _DayCard({
    required this.dayOfWeek,
    required this.dayDate,
    required this.isToday,
    required this.activities,
    required this.unplannedTasks,
    required this.onTap,
  });

  String get _dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayNumberFormat = DateFormat('d MMMM', 'fr_FR');
    final formattedDate = dayNumberFormat.format(dayDate);

    final pendingUnplanned = unplannedTasks.where((t) => !t.isCompleted).toList();

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isToday ? AppColors.accentPrimary : AppColors.border,
          width: isToday ? 1.5 : 0.8,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête du jour : Nom, Date, Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.accentPrimary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isToday ? AppColors.accentPrimary : AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AppText.heading(
                          _dayName.substring(0, 1),
                          fontSize: 15,
                          color: isToday
                              ? AppColors.background
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppText.heading(
                                _dayName,
                                fontSize: 16,
                                color: isToday ? AppColors.accentPrimary : AppColors.textPrimary,
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPrimary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const AppText.label(
                                    'AUJOURD\'HUI',
                                    color: AppColors.background,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          AppText.caption(
                            formattedDate,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (pendingUnplanned.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.topaze.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.topaze.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded,
                                  size: 13, color: AppColors.topaze),
                              const SizedBox(width: 3),
                              AppText.label(
                                '${pendingUnplanned.length}',
                                color: AppColors.topaze,
                                fontSize: 11,
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: activities.isEmpty
                              ? AppColors.surfaceVariant
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: activities.isEmpty
                                ? AppColors.border
                                : AppColors.border,
                          ),
                        ),
                        child: AppText.caption(
                          '${activities.length} act.',
                          color: activities.isEmpty
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              if (activities.isNotEmpty || unplannedTasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...activities.map(
                      (activity) => InkWell(
                        onTap: () {
                          if (activity.isRecurring) {
                            ShiftOccurrenceModal.show(
                              context: context,
                              activity: activity,
                              occurrenceDate: dayDate,
                              onUpdated: () => Get.find<WeekController>().loadData(),
                            );
                          } else {
                            onTap();
                          }
                        },
                        onLongPress: activity.isRecurring
                            ? () => ShiftOccurrenceModal.show(
                                  context: context,
                                  activity: activity,
                                  occurrenceDate: dayDate,
                                  onUpdated: () => Get.find<WeekController>().loadData(),
                                )
                            : null,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            border: Border(
                              left: BorderSide(
                                color: activity.category.color,
                                width: 3,
                              ),
                              top: const BorderSide(color: AppColors.border, width: 0.5),
                              right: const BorderSide(color: AppColors.border, width: 0.5),
                              bottom: const BorderSide(color: AppColors.border, width: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppText.body(
                                activity.title,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                decoration: activity.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: activity.isCompleted
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 6),
                              // Horaires en police IBM Plex Mono (variant time)
                              AppText.time(
                                activity.timeRangeFormatted,
                                fontSize: 10,
                                color: activity.category.color,
                              ),
                              if (activity.isRecurring) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.sync_rounded,
                                  size: 11,
                                  color: AppColors.accentPrimary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (pendingUnplanned.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          border: Border(
                            left: BorderSide(color: AppColors.topaze, width: 3),
                            top: BorderSide(color: AppColors.border, width: 0.5),
                            right: BorderSide(color: AppColors.border, width: 0.5),
                            bottom: BorderSide(color: AppColors.border, width: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                size: 12, color: AppColors.topaze),
                            const SizedBox(width: 4),
                            AppText.body(
                              '${pendingUnplanned.length} imprévu(s)',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.topaze,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
