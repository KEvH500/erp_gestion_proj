import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Variantes typographiques pour le système de design "Cadran de précision"
enum AppTextStyleVariant {
  /// Titres éditoriaux et grands en-têtes (Google Fonts Fraunces)
  heading,

  /// Sous-titres et titres de sections (Google Fonts Inter)
  subtitle,

  /// Texte de corps courant (Google Fonts Inter)
  body,

  /// Libellés, badges, boutons (Google Fonts Inter)
  label,

  /// Légendes, métadonnées, notes (Google Fonts Inter)
  caption,

  /// Horaires, durées, compteurs (Google Fonts IBM Plex Mono)
  time,
}

/// Widget typographique centralisé assurant la cohérence des polices
class AppText extends StatelessWidget {
  final String text;
  final AppTextStyleVariant variant;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? height;
  final double? letterSpacing;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextStyleVariant.body,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  const AppText.heading(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w700,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing = -0.5,
  }) : variant = AppTextStyleVariant.heading;

  const AppText.subtitle(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing,
  }) : variant = AppTextStyleVariant.subtitle;

  const AppText.body(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height = 1.4,
    this.letterSpacing,
  }) : variant = AppTextStyleVariant.body;

  const AppText.label(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing = 0.3,
  }) : variant = AppTextStyleVariant.label;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 11,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing,
  }) : variant = AppTextStyleVariant.caption;

  const AppText.time(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.decoration,
    this.height = 1.2,
    this.letterSpacing = -0.2,
  }) : variant = AppTextStyleVariant.time;

  TextStyle get _style {
    final effectiveColor = color ??
        (variant == AppTextStyleVariant.caption
            ? AppColors.textSecondary
            : (variant == AppTextStyleVariant.heading
                ? AppColors.textPrimary
                : AppColors.textPrimary));

    switch (variant) {
      case AppTextStyleVariant.heading:
        return GoogleFonts.fraunces(
          fontSize: fontSize ?? 20,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: effectiveColor,
          height: height,
          letterSpacing: letterSpacing ?? -0.5,
          decoration: decoration,
        );

      case AppTextStyleVariant.subtitle:
        return GoogleFonts.inter(
          fontSize: fontSize ?? 15,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: effectiveColor,
          height: height,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );

      case AppTextStyleVariant.body:
        return GoogleFonts.inter(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: effectiveColor,
          height: height ?? 1.4,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );

      case AppTextStyleVariant.label:
        return GoogleFonts.inter(
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: effectiveColor,
          height: height,
          letterSpacing: letterSpacing ?? 0.3,
          decoration: decoration,
        );

      case AppTextStyleVariant.caption:
        return GoogleFonts.inter(
          fontSize: fontSize ?? 11,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: effectiveColor,
          height: height,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );

      case AppTextStyleVariant.time:
        return GoogleFonts.ibmPlexMono(
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: effectiveColor,
          height: height ?? 1.2,
          letterSpacing: letterSpacing ?? -0.2,
          decoration: decoration,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
