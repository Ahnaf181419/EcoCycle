import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/string_extensions.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final String? subcategory;
  final double iconSize;
  final bool showLabel;
  final bool compact;

  const CategoryBadge({
    super.key,
    required this.category,
    this.subcategory,
    this.iconSize = 32,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);
    final lightColor = AppColors.categoryLightColor(category);
    final darkColor = AppColors.categoryDarkColor(category);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 16,
        vertical: compact ? 6 : 12,
      ),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(compact ? 12 : 24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: _categoryIcon,
            color: darkColor,
            size: compact ? 20 : iconSize,
            strokeWidth: compact ? 1.5 : 2.0,
          ),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.categoryDisplayName,
                  style:
                      (compact
                              ? AppTypography.labelMedium
                              : AppTypography.labelLarge)
                          .copyWith(
                            color: darkColor,
                            fontWeight: FontWeight.w600,
                          ),
                ),
                if (subcategory != null && !compact)
                  Text(
                    subcategory!.capitalized,
                    style: AppTypography.bodySmall.copyWith(
                      color: darkColor.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<List<dynamic>> get _categoryIcon {
    switch (category.toLowerCase()) {
      case 'recyclable':
        return HugeIcons.strokeRoundedRecycle01;
      case 'organic':
        return HugeIcons.strokeRoundedLeaf01;
      case 'e_waste':
      case 'ewaste':
        return HugeIcons.strokeRoundedChip;
      case 'hazardous':
        return HugeIcons.strokeRoundedAlert01;
      default:
        return HugeIcons.strokeRoundedRecycle01;
    }
  }
}
