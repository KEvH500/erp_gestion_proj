import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import 'export_controller.dart';

/// Vue d'export hebdomadaire des tâches avec prévisualisation complète
class ExportView extends GetView<ExportController> {
  const ExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.heading('Export Hebdomadaire', fontSize: 18),
            AppText.caption('Toutes les tâches et horaires de la semaine'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_rounded, color: AppColors.textPrimary),
            tooltip: 'Copier le résumé',
            onPressed: controller.copySummaryToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.accentPrimary),
            tooltip: 'Semaine courante',
            onPressed: controller.goToCurrentWeek,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final days = controller.daysOfWeek;
        final totalCount = controller.totalActivitiesCount;

        return Column(
          children: [
            // 1. Barre de navigation de la semaine
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: controller.previousWeek,
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 28),
                    tooltip: 'Semaine précédente',
                  ),
                  Column(
                    children: [
                      AppText.heading(
                        controller.weekTitleFormatted,
                        fontSize: 15,
                        color: AppColors.accentPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText.caption(
                        '$totalCount tâche${totalCount > 1 ? "s" : ""} au total',
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: controller.nextWeek,
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary, size: 28),
                    tooltip: 'Semaine suivante',
                  ),
                ],
              ),
            ),

            // 2. Prévisualisation groupée par jour
            Expanded(
              child: totalCount == 0
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          AppText.body('Aucune tâche planifiée pour cette semaine.', color: AppColors.textMuted),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final acts = controller.weekActivitiesMap[day] ?? [];
                        final dayName = DateFormat('EEEE d MMMM', 'fr_FR').format(day);
                        final capitalizedDay = dayName[0].toUpperCase() + dayName.substring(1);

                        if (acts.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // En-tête du jour
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentPrimary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AppText.heading(capitalizedDay, fontSize: 15),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: AppText.caption(
                                      '${acts.length}',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Cartes des tâches
                              ...acts.map((act) => _buildExportTaskCard(act)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),

      // 3. Barre d'action fixe en bas
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Obx(
          () => Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.copySummaryToClipboard,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textPrimary),
                  label: const AppText.label('Copier le texte', color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.isExporting.value
                      ? null
                      : controller.exportAndShareCsv,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: controller.isExporting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: const AppText.label(
                    'Exporter CSV',
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportTaskCard(Activity act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: act.category.color, width: 3.5),
          top: const BorderSide(color: AppColors.border, width: 0.5),
          right: const BorderSide(color: AppColors.border, width: 0.5),
          bottom: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.body(
                        act.title,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (act.isLocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accentPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 10, color: AppColors.accentPrimary),
                            SizedBox(width: 2),
                            AppText.label(
                              'Verrouillée',
                              fontSize: 9,
                              color: AppColors.accentPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (act.location != null && act.location!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      AppText.caption(act.location!, color: AppColors.textMuted),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.time(
                act.timeRangeFormatted,
                fontSize: 12,
                color: act.category.color,
              ),
              AppText.caption(
                act.category.label,
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
