import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Contrat commun à tout champ de formulaire réactif de l'application
abstract class AppFormField<T> extends StatelessWidget {
  final String? formControlName;
  final FormControl<T>? formControl;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final bool isRequired;

  const AppFormField({
    super.key,
    this.formControlName,
    this.formControl,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.validationMessages,
    this.isRequired = false,
  }) : assert(
          formControlName != null || formControl != null,
          'Vous devez fournir soit un formControlName, soit un formControl.',
        );
}
