import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../core/contracts/app_form_field.dart';

/// Champ de texte réactif s'intégrant avec reactive_forms et respectant le contrat AppFormField<String>
class AppTextInputField extends AppFormField<String> {
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<FormControl<String>>? onSubmitted;
  final Widget? suffix;

  const AppTextInputField({
    super.key,
    super.formControlName,
    super.formControl,
    required super.label,
    super.hint,
    super.prefixIcon,
    super.validationMessages,
    super.isRequired,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultValidationMessages = {
      ValidationMessage.required: (error) => '$label est requis.',
      ValidationMessage.minLength: (error) =>
          '$label doit comporter au moins ${(error as Map)['requiredLength']} caractères.',
      ValidationMessage.number: (error) => 'Veuillez entrer un nombre valide.',
      ...?validationMessages,
    };

    final inputDecoration = InputDecoration(
      labelText: isRequired ? '$label *' : label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffix: suffix,
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
      return ReactiveTextField<String>(
        formControl: formControl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        validationMessages: defaultValidationMessages,
        decoration: inputDecoration,
      );
    }

    return ReactiveTextField<String>(
      formControlName: formControlName!,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      validationMessages: defaultValidationMessages,
      decoration: inputDecoration,
    );
  }
}
