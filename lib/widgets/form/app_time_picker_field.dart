import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../core/contracts/app_form_field.dart';

/// Champ de sélection d'heure réactif s'intégrant avec reactive_forms
class AppTimePickerField extends AppFormField<TimeOfDay> {
  const AppTimePickerField({
    super.key,
    super.formControlName,
    super.formControl,
    required super.label,
    super.hint,
    super.prefixIcon = Icons.access_time_rounded,
    super.validationMessages,
    super.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReactiveValueListenableBuilder<TimeOfDay>(
      formControlName: formControlName,
      formControl: formControl,
      builder: (context, control, child) {
        final time = control.value;
        final timeFormatted = time != null
            ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
            : (hint ?? 'Sélectionner');

        final hasError = control.touched && control.invalid;

        return InkWell(
          onTap: () async {
            control.markAsTouched();
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
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
                        timeFormatted,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: time == null
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
