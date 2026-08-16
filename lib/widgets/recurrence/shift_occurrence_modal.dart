import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/activity_repository.dart';
import '../../models/activity.dart';
import '../../models/recurrence_exception.dart';
import '../../services/overlap_checker.dart';
import '../../theme/app_theme.dart';
import '../../utils/notification_service.dart';
import '../../widgets/core/app_text.dart';

/// Modale pour décaler une occurrence d'une tâche récurrente, la détacher ou la supprimer individuellement
class ShiftOccurrenceModal extends StatefulWidget {
  final Activity activity;
  final DateTime occurrenceDate;
  final VoidCallback onUpdated;

  const ShiftOccurrenceModal({
    super.key,
    required this.activity,
    required this.occurrenceDate,
    required this.onUpdated,
  });

  static Future<void> show({
    required BuildContext context,
    required Activity activity,
    required DateTime occurrenceDate,
    required VoidCallback onUpdated,
  }) {
    return Get.bottomSheet(
      ShiftOccurrenceModal(
        activity: activity,
        occurrenceDate: occurrenceDate,
        onUpdated: onUpdated,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ShiftOccurrenceModal> createState() => _ShiftOccurrenceModalState();
}

class _ShiftOccurrenceModalState extends State<ShiftOccurrenceModal> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.occurrenceDate.year,
      widget.occurrenceDate.month,
      widget.occurrenceDate.day,
    );
    _selectedStartTime = TimeOfDay(
      hour: widget.activity.startHour,
      minute: widget.activity.startMinute,
    );
    _selectedEndTime = TimeOfDay(
      hour: widget.activity.endHour,
      minute: widget.activity.endMinute,
    );
  }

  String _formatDate(DateTime date) {
    final raw = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    return raw.isNotEmpty ? '${raw[0].toUpperCase()}${raw.substring(1)}' : raw;
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null) {
      final currentDuration = (_selectedEndTime.hour * 60 + _selectedEndTime.minute) -
          (_selectedStartTime.hour * 60 + _selectedStartTime.minute);
      final duration = currentDuration > 0 ? currentDuration : 60;

      final newEndMinutes = (picked.hour * 60 + picked.minute) + duration;
      final newEndHour = (newEndMinutes ~/ 60) % 24;
      final newEndMinute = newEndMinutes % 60;

      setState(() {
        _selectedStartTime = picked;
        _selectedEndTime = TimeOfDay(hour: newEndHour, minute: newEndMinute);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  // Raccourcis rapides
  void _shortcutNextWeek() {
    setState(() {
      _selectedDate = widget.occurrenceDate.add(const Duration(days: 7));
    });
  }

  void _shortcutTomorrow() {
    setState(() {
      _selectedDate = widget.occurrenceDate.add(const Duration(days: 1));
    });
  }

  void _shortcutPlus2Hours() {
    final newStartHour = (_selectedStartTime.hour + 2) % 24;
    final newEndHour = (_selectedEndTime.hour + 2) % 24;
    setState(() {
      _selectedStartTime = TimeOfDay(hour: newStartHour, minute: _selectedStartTime.minute);
      _selectedEndTime = TimeOfDay(hour: newEndHour, minute: _selectedEndTime.minute);
    });
  }

  Future<void> _applyShift() async {
    final repo = Get.find<IActivityRepository>();
    final notifService = Get.find<NotificationService>();

    // Contrôle de non-chevauchement sur la date et créneau cible
    final allActivities = repo.getAllActivities();
    final checkResult = OverlapChecker.findOverlaps(
      targetDate: _selectedDate,
      startHour: _selectedStartTime.hour,
      startMinute: _selectedStartTime.minute,
      endHour: _selectedEndTime.hour,
      endMinute: _selectedEndTime.minute,
      isLocked: widget.activity.isLocked,
      allActivities: allActivities,
      excludeActivityId: widget.activity.id,
    );

    if (checkResult.hasBlockingConflicts) {
      final proceed = await _showShiftConflictDialog(checkResult.blockingConflicts);
      if (proceed != true) {
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final exception = RecurrenceException(
        taskId: widget.activity.id,
        originalDate: widget.occurrenceDate,
        newDate: _selectedDate,
        newStartHour: _selectedStartTime.hour,
        newStartMinute: _selectedStartTime.minute,
        newEndHour: _selectedEndTime.hour,
        newEndMinute: _selectedEndTime.minute,
      );

      await repo.addRecurrenceException(widget.activity.id, exception);

      final updatedAct = repo.getActivityById(widget.activity.id);
      if (updatedAct != null) {
        await notifService.scheduleActivityNotification(updatedAct);
      }

      widget.onUpdated();
      Get.back();

      Get.snackbar(
        'Occurrence décalée',
        'Déplacée au ${_formatDate(_selectedDate)} (${_formatTime(_selectedStartTime)} - ${_formatTime(_selectedEndTime)}). Le reste de la série reste inchangé.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accentPrimary,
        colorText: AppColors.background,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool?> _showShiftConflictDialog(List<Activity> conflicts) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.rubis),
            SizedBox(width: 8),
            AppText.heading('Conflit d\'horaires', fontSize: 16),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText.body(
              'Le créneau sélectionné chevauche les tâches suivantes :',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            ...conflicts.map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  border: Border(
                    left: BorderSide(color: c.category.color, width: 3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText.body(c.title, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    AppText.time(c.timeRangeFormatted, color: c.category.color, fontSize: 11),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const AppText.caption(
              'Voulez-vous quand même forcer ce déplacement en dérogeant à la règle de non-chevauchement ?',
              color: AppColors.textMuted,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const AppText.label('Modifier l\'horaire', color: AppColors.textPrimary),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.background,
            ),
            child: const AppText.label('Déplacer quand même', color: AppColors.background),
          ),
        ],
      ),
    );
  }

  Future<void> _detachAsIndependentTask() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.content_cut_rounded, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Détacher l\'événement'),
          ],
        ),
        content: const Text(
          'Cette occurrence sera complètement détachée de la série récurrente et deviendra une tâche indépendante.\n\n'
          'Elle pourra être modifiée ou supprimée seule sans jamais affecter les autres semaines de la série.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirmer le détachement'),
            style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final repo = Get.find<IActivityRepository>();
      final notifService = Get.find<NotificationService>();

      final detachedActivity = Activity(
        id: const Uuid().v4(),
        title: widget.activity.title,
        description: widget.activity.description,
        startDate: _selectedDate,
        startHour: _selectedStartTime.hour,
        startMinute: _selectedStartTime.minute,
        endHour: _selectedEndTime.hour,
        endMinute: _selectedEndTime.minute,
        category: widget.activity.category,
        location: widget.activity.location,
        reminderMinutesBefore: widget.activity.reminderMinutesBefore,
        recurrenceRule: null, // Devenue indépendante
      );

      await repo.detachOccurrence(
        widget.activity.id,
        widget.occurrenceDate,
        detachedActivity,
      );

      // Replanification des notifications
      final updatedParent = repo.getActivityById(widget.activity.id);
      if (updatedParent != null) {
        await notifService.scheduleActivityNotification(updatedParent);
      }
      await notifService.scheduleActivityNotification(detachedActivity);

      widget.onUpdated();
      Get.back();

      Get.snackbar(
        'Occurrence détachée',
        'Créée comme événement indépendant pour le ${_formatDate(_selectedDate)}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.indigo,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _cancelThisOccurrence() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer cette occurrence ?'),
        content: Text(
          'Seule l\'occurrence du ${DateFormat('d MMMM yyyy', 'fr_FR').format(widget.occurrenceDate)} sera supprimée.\n\nToutes les autres semaines de la série resteront intactes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Supprimer uniquement celle-ci'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final repo = Get.find<IActivityRepository>();
      final notifService = Get.find<NotificationService>();

      final exception = RecurrenceException(
        taskId: widget.activity.id,
        originalDate: widget.occurrenceDate,
        isCancelled: true,
      );

      await repo.addRecurrenceException(widget.activity.id, exception);

      final updatedParent = repo.getActivityById(widget.activity.id);
      if (updatedParent != null) {
        await notifService.scheduleActivityNotification(updatedParent);
      }

      widget.onUpdated();
      Get.back();

      Get.snackbar(
        'Occurrence supprimée',
        'L\'occurrence du ${DateFormat('d MMMM', 'fr_FR').format(widget.occurrenceDate)} a été retirée de la série.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Titre et info récurrence
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule_send_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Décaler cette occurrence',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.activity.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.activity.category.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

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
                        'Occurrence du ${DateFormat('d MMMM yyyy', 'fr_FR').format(widget.occurrenceDate)} • Série : ${widget.activity.recurrenceRule?.humanReadableDescription ?? "Récurrente"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Raccourcis rapides',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),

              // Raccourcis chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.next_week_outlined, size: 16),
                    label: const Text('Semaine prochaine (+7j)'),
                    onPressed: _shortcutNextWeek,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.today_outlined, size: 16),
                    label: const Text('Demain (+1j)'),
                    onPressed: _shortcutTomorrow,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.more_time_rounded, size: 16),
                    label: const Text('Reporter de 2h (+2h)'),
                    onPressed: _shortcutPlus2Hours,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              const Text(
                'Nouvelle date & horaires pour cette occurrence',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Sélecteur de date
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text(
                        'Changer',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sélecteur d'heures (Début et Fin)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Début',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(_selectedStartTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fin',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(_selectedEndTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bouton Décaler
              FilledButton.icon(
                onPressed: _isSaving ? null : _applyShift,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isSaving ? 'Enregistrement...' : 'Valider le décalage (cette semaine)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Actions avancées (Détacher / Supprimer cette occurrence)
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _detachAsIndependentTask,
                icon: const Icon(Icons.content_cut_rounded, color: Colors.indigo),
                label: const Text(
                  'Détacher comme événement indépendant',
                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 8),

              TextButton.icon(
                onPressed: _isSaving ? null : _cancelThisOccurrence,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                label: const Text(
                  'Supprimer cette occurrence uniquement',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
