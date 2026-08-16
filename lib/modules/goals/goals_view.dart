import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/router/app_router.dart';
import '../../models/goal.dart';
import 'widgets/add_edit_goal_modal.dart';
import 'goals_controller.dart';

/// Vue du tableau de bord des objectifs et de progression
class GoalsView extends GetView<GoalsController> {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(controller.selectedDate.value);
    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objectifs & Suivi',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            Text(
              'Temps plein, temps limité & indicateurs',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: () => Get.toNamed(Routes.DAILY_REPORT),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: const Text('Rapport 📊', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [theme.colorScheme.primary.withValues(alpha: 0.08), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
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
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          color: overallRate >= 1.0
                              ? Colors.green
                              : (overallRate >= 0.5 ? Colors.amber : theme.colorScheme.primary),
                        ),
                        Text(
                          '${(overallRate * 100).toInt()}%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(capitalizedDate, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          '$achievedGoals sur $totalGoals accomplis',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          overallRate >= 1.0
                              ? 'Tous vos objectifs sont atteints ! 🌟'
                              : (overallRate >= 0.5
                                  ? 'Excellente progression, continuez ! 🚀'
                                  : 'Définissez vos priorités du jour.'),
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
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
