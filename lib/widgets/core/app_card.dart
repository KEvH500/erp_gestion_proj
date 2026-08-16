import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_text.dart';

/// Carte de tâche respectant la direction "Cadran de précision" :
/// - Fond surface (#1E2027)
/// - Accent plat à gauche (bordure 3px)
/// - Coins arrondis uniquement à droite
class AppCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final Color categoryColor;
  final String? subtitle;
  final String? location;
  final bool isCompleted;
  final bool isRecurring;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const AppCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.categoryColor,
    this.subtitle,
    this.location,
    this.isCompleted = false,
    this.isRecurring = false,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border(
              left: BorderSide(color: categoryColor, width: 3.5),
              top: const BorderSide(color: AppColors.border, width: 0.5),
              right: const BorderSide(color: AppColors.border, width: 0.5),
              bottom: const BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText.body(
                            title,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRecurring) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.sync_rounded,
                            size: 13,
                            color: AppColors.accentPrimary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Horaire en police IBM Plex Mono (variant time) avec la couleur de la catégorie
                        AppText.time(
                          timeRange,
                          color: categoryColor,
                          fontSize: 11,
                        ),
                        if (location != null && location!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: AppText.caption(
                              location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else if (isCompleted) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.jade),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
