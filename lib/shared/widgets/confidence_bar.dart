import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';

class ConfidenceBar extends StatefulWidget {
  final double confidence;
  final String label;
  final Color? color;
  final bool animate;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.label = '',
    this.color,
    this.animate = true,
  });

  @override
  State<ConfidenceBar> createState() => _ConfidenceBarState();
}

class _ConfidenceBarState extends State<ConfidenceBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationSlow,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.confidence,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ConfidenceBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidence != widget.confidence) {
      _animation = Tween<double>(
        begin: 0,
        end: widget.confidence,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _barColor {
    if (widget.color != null) return widget.color!;
    if (widget.confidence >= 0.7) return AppColors.success;
    if (widget.confidence >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _animation.value,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: AppTypography.statSmall.copyWith(color: _barColor),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
