import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';

class PointsDisplay extends StatefulWidget {
  final int points;
  final bool animate;
  final bool isLarge;
  final String? label;

  const PointsDisplay({
    super.key,
    required this.points,
    this.animate = true,
    this.isLarge = false,
    this.label,
  });

  @override
  State<PointsDisplay> createState() => _PointsDisplayState();
}

class _PointsDisplayState extends State<PointsDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationCelebration,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
      _scaleAnimation = _controller.view;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.isLarge
        ? AppTypography.statLarge
        : AppTypography.statMedium;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isLarge ? 24 : 16,
          vertical: widget.isLarge ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCoins01,
              color: Colors.white,
              size: widget.isLarge ? 28 : 20,
              strokeWidth: 1.5,
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.points > 0 ? '+' : ''}${widget.points}',
              style: textStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(width: 4),
              Text(
                widget.label!,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
