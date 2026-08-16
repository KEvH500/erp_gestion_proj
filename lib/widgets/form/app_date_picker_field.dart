import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../core/contracts/app_form_field.dart';

/// Champ de sélection de date réactif s'intégrant avec reactive_forms
class AppDatePickerField extends AppFormField<DateTime> {
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePickerField({
    super.key,
    super.formControlName,
    super.formControl,
    required super.label,
    super.hint,
    super.prefixIcon = Icons.calendar_today_rounded,
    super.validationMessages,
    super.isRequired,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReactiveValueListenableBuilder<DateTime>(
      formControlName: formControlName,
      formControl: formControl,
      builder: (context, control, child) {
        final date = control.value;
        final dateFormatted = date != null
            ? DateFormat('d MMMM yyyy', 'fr_FR').format(date)
            : (hint ?? 'Sélectionner une date');

        final hasError = control.touched && control.invalid;

        return InkWell(
          onTap: () async {
            control.markAsTouched();
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? now,
              firstDate: firstDate ?? DateTime(2020),
              lastDate: lastDate ?? DateTime(2040),
              locale: const Locale('fr', 'FR'),
            );
            if (picked != null) {
              control.value = picked;
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? Colors.redAccent
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: 20,
                    color: hasError ? Colors.redAccent : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRequired ? '$label *' : label,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasError
                              ? Colors.redAccent
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: date == null
                              ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}
