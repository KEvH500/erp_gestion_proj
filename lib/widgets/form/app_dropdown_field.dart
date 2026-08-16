import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../core/contracts/app_form_field.dart';

/// Champ de sélection déroulante réactif générique s'intégrant avec reactive_forms
class AppDropdownField<T> extends AppFormField<T> {
  final List<DropdownMenuItem<T>> items;

  const AppDropdownField({
    super.key,
    super.formControlName,
    super.formControl,
    required super.label,
    super.hint,
    super.prefixIcon,
    super.validationMessages,
    super.isRequired,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultValidationMessages = {
      ValidationMessage.required: (error) => '$label est requis.',
      ...?validationMessages,
    };

    final inputDecoration = InputDecoration(
      labelText: isRequired ? '$label *' : label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    if (formControl != null) {
      return ReactiveDropdownField<T>(
        formControl: formControl,
        items: items,
        validationMessages: defaultValidationMessages,
        decoration: inputDecoration,
      );
    }

    return ReactiveDropdownField<T>(
      formControlName: formControlName!,
      items: items,
      validationMessages: defaultValidationMessages,
      decoration: inputDecoration,
    );
  }
}
