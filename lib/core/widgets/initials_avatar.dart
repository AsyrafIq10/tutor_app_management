import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A round avatar showing someone's initials, e.g. "DL".
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.borderColor,
  });

  final String initials;
  final double size;

  /// Used by [AvatarStack] so overlapping avatars stay readable.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Overlapping avatars, e.g. for students in a class.
/// Shows at most [max] avatars and then a "+N" circle.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.initials,
    this.size = 32,
    this.max = 3,
  });

  final List<String> initials;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = initials.take(max).toList();
    final extra = initials.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();
    final step = size * 0.65;

    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: InitialsAvatar(
                initials: shown[i],
                size: size,
                borderColor: AppColors.card,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: step * shown.length,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.neutralSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: size * 0.34,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
