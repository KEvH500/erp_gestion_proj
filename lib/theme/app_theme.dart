import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classe centralisée des jetons de couleurs du thème "Cadran de précision"
abstract class AppColors {
  // Neutres (fond et surfaces)
  /// Fond principal, anthracite chaud (#14151A — jamais de noir pur #000000)
  static const Color background = Color(0xFF14151A);

  /// Surfaces élevées, cartes, modals (#1E2027)
  static const Color surface = Color(0xFF1E2027);

  /// Éléments secondaires, repères, conteneurs (#24262E)
  static const Color surfaceVariant = Color(0xFF24262E);

  /// Bordures fines et séparateurs (#2C2E36)
  static const Color border = Color(0xFF2C2E36);

  /// Texte principal blanc cassé chaud (#F2F0EA — jamais de blanc pur #FFFFFF)
  static const Color textPrimary = Color(0xFFF2F0EA);

  /// Texte secondaire (#9A9AA2)
  static const Color textSecondary = Color(0xFF9A9AA2);

  /// Texte estompé / disabled (#6C6C74)
  static const Color textMuted = Color(0xFF6C6C74);

  // Accent primaire (Actions, boutons, CTA, repère horaire doré)
  /// Accent doré / laiton (#E8A33D)
  static const Color accentPrimary = Color(0xFFE8A33D);

  /// Accent doré assombri pour les états pressés / hover (~12% plus sombre : #CC8F36)
  static const Color accentPrimaryHover = Color(0xFFCC8F36);

  // Palette Pierres Précieuses (Catégories et Projets)
  static const Color saphir = Color(0xFF4C8DFF);
  static const Color jade = Color(0xFF34C79E);
  static const Color amethyste = Color(0xFF9B6BFF);
  static const Color topaze = Color(0xFFF2C14E);
  static const Color rubis = Color(0xFFE8465C);

  /// Palette standard des 5 pierres précieuses pour catégories & sélecteurs
  static const List<Color> categoryPalette = [
    saphir,
    jade,
    amethyste,
    topaze,
    rubis,
  ];
}

/// Thème global de l'application appliquant la direction "Cadran de précision"
class AppTheme {
  /// Thème Sombre d'excellence "Cadran de précision"
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.accentPrimary,
        onPrimary: AppColors.background,
        primaryContainer: AppColors.surfaceVariant,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.saphir,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        error: AppColors.rubis,
        onError: AppColors.textPrimary,
      ),
    );

    final interTextTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: interTextTheme.copyWith(
        displayLarge: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.fraunces(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
        bodySmall: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
        labelLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
        labelMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
        labelSmall: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.fraunces(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.background,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  /// Thème clair rétro-compatible (adapté avec les accents chauds et contrastes)
  static ThemeData get lightTheme => darkTheme;
}
