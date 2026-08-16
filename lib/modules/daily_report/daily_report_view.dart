import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import 'daily_report_controller.dart';

/// Vue du rapport quotidien analytique de fin de journée
class DailyReportView extends GetView<DailyReportController> {
  const DailyReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.heading('Rapport de Journée', fontSize: 18),
            AppText.caption('Bilan et performance du jour'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_rounded, color: AppColors.textPrimary),
            tooltip: 'Copier le résumé',
            onPressed: controller.copyReportToClipboard,
          ),
        ],
      ),
      body: Obx(() {
        final r = controller.report.value;
        if (r == null || controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
        final formattedDate = dateFormat.format(r.date);
        final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Sélecteur de date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.heading(capitalizedDate, fontSize: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      controller.selectDate(picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: const AppText.label('Changer date', fontSize: 12),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Score Global
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: r.score >= 75
                          ? AppColors.jade.withValues(alpha: 0.2)
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: AppText.time(
                      '${r.score}',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: r.score >= 75 ? AppColors.jade : AppColors.accentPrimary,
                    ),
                  ),   ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Score de Productivité / 100', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(r.appreciation, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Cartes statistiques
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    isDark: isDark,
                    title: 'Emploi du temps',
                    value: '${r.activitiesCompleted} / ${r.activitiesTotal}',
                    subtitle: '${r.totalCompletedTimeFormatted} accomplies',
                    icon: Icons.calendar_month_rounded,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    isDark: isDark,
                    title: 'Imprévus résolus',
                    value: '${r.unplannedTasksCompleted} / ${r.unplannedTasksTotal}',
                    subtitle: '${(r.unplannedResolutionRate * 100).toInt()}% traités',
                    icon: Icons.bolt_rounded,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    isDark: isDark,
                    title: 'Objectifs validés',
                    value: '${r.goalsAchieved} / ${r.goalsTotal}',
                    subtitle: r.goalsTotal > 0 ? '${((r.goalsAchieved / r.goalsTotal) * 100).toInt()}% réussis' : 'Aucun objectif',
                    icon: Icons.track_changes_rounded,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    isDark: isDark,
                    title: 'Temps planifié',
                    value: r.totalPlannedTimeFormatted,
                    subtitle: 'Durée théorique',
                    icon: Icons.timer_outlined,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Répartition par catégorie
            const Text('Répartition du temps accompli', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (r.categoryDurationMinutes.isEmpty)
              const Text('Aucune activité accomplie enregistrée.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
            else
              ...r.categoryDurationMinutes.entries.map((entry) {
                final cat = entry.key;
                final mins = entry.value;
                final pct = r.completedDurationMinutes > 0 ? (mins / r.completedDurationMinutes) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(cat.icon, size: 14, color: cat.color),
                              const SizedBox(width: 6),
                              Text(cat.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Text('${(mins ~/ 60)}h ${(mins % 60).toString().padLeft(2, "0")}m (${(pct * 100).toInt()}%)', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          color: cat.color,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // 5. Bouton Copier / Partager
            FilledButton.icon(
              onPressed: controller.copyReportToClipboard,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              icon: const Icon(Icons.share_rounded),
              label: const Text('Copier & Partager le rapport', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
