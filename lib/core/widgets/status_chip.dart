import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum StatusTone { mint, neutral, warning, error }

/// A small pill label, e.g. "Group", "Inactive", "Overdue".
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.mint,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      StatusTone.mint => (AppColors.mintSoft, AppColors.primary),
      StatusTone.neutral => (AppColors.neutralSoft, AppColors.textMuted),
      StatusTone.warning => (AppColors.warningSoft, AppColors.warning),
      StatusTone.error => (AppColors.warningSoft, AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
