import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/router/app_router.dart';
import '../../models/goal.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_text.dart';
import 'widgets/add_edit_goal_modal.dart';
import 'goals_controller.dart';

/// Vue du tableau de bord des objectifs et de progression
class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(controller.selectedDate.value);
    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.heading('Objectifs & Suivi', fontSize: 18),
            AppText.caption('Temps plein, temps limité & indicateurs'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: () => Get.toNamed(Routes.DAILY_REPORT),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.accentPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.analytics_outlined, size: 16, color: AppColors.accentPrimary),
              label: const AppText.label('Rapport 📊', fontSize: 12, color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final goals = controller.goals;
        final filteredGoals = controller.filteredGoals;
        final totalGoals = goals.length;
        final achievedGoals = controller.achievedGoalsCount;
        final overallRate = controller.overallCompletionRate;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            // 1. Dashboard jauge circulaire
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: overallRate,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceVariant,
                          color: overallRate >= 1.0
                              ? AppColors.jade
                              : (overallRate >= 0.5 ? AppColors.topaze : AppColors.accentPrimary),
                        ),
                        AppText.time(
                          '${(overallRate * 100).toInt()}%',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.caption(capitalizedDate, color: AppColors.textSecondary),
                        const SizedBox(height: 4),
                        AppText.body(
                          '$achievedGoals sur $totalGoals accomplis',
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        const SizedBox(height: 4),
                        AppText.caption(
                          overallRate >= 1.0
                              ? 'Tous vos objectifs sont atteints ! 🌟'
                              : (overallRate >= 0.5
                                  ? 'Excellente progression, continuez ! 🚀'
                                  : 'Définissez vos priorités du jour.'),
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous (${goals.length})', null),
                  const SizedBox(width: 6),
                  _buildFilterChip('⏱️ Temps Limité', GoalType.timeLimited),
                  const SizedBox(width: 6),
                  _buildFilterChip('⏳ Temps Plein', GoalType.fullTime),
                  const SizedBox(width: 6),
                  _buildFilterChip('📋 Tâches', GoalType.taskCount),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Liste des objectifs
            if (filteredGoals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.track_changes_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('Aucun objectif dans cette catégorie.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              )
            else
              ...filteredGoals.map((goal) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(goal.type.icon, color: goal.type.color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                goal.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                goal.isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                                color: goal.isCompleted ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => controller.toggleGoal(goal.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: goal.progressPercentage,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            color: goal.type.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal.progressDisplay, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text(goal.progressPercentageFormatted, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: goal.type.color)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditGoalModal.show(context).then((_) => controller.loadGoals()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Objectif', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String label, GoalType? type) {
    final isSelected = controller.filterType.value == type;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => controller.setFilterType(type),
    );
  }
}
