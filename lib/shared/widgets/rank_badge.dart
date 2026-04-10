import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class RankBadge extends StatelessWidget {
  final int rank;
  final bool isCurrentUser;

  const RankBadge({super.key, required this.rank, this.isCurrentUser = false});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (rank == 1) {
      bgColor = const Color(0xFFFFD700);
      textColor = const Color(0xFF5D4200);
    } else if (rank == 2) {
      bgColor = const Color(0xFFC0C0C0);
      textColor = const Color(0xFF4A4A4A);
    } else if (rank == 3) {
      bgColor = const Color(0xFFCD7F32);
      textColor = const Color(0xFF4A2800);
    } else {
      bgColor = AppColors.surfaceVariant;
      textColor = AppColors.textSecondary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: rank <= 3 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: rank > 3 ? BorderRadius.circular(8) : null,
        border: isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTypography.statSmall.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
