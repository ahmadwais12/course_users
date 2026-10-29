import 'package:flutter/material.dart';
import 'package:course_users/ui/ui_helper.dart';

class AppProgress extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  final bool showLabel;
  final String? label;

  const AppProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
    this.showLabel = false,
    this.label,
  });

  factory AppProgress.circular({
    required double value,
    Color? color,
    double size = 60,
    double strokeWidth = 6,
  }) =>
      AppProgress(value: value, color: color, showLabel: true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;

    if (showLabel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: barColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: height,
            ),
          ),
          if (label != null) Gap.h4,
          if (label != null)
            Text(label!, style: AppText.caption(ctx: context)),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: barColor.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
        minHeight: height,
      ),
    );
  }
}

class AppCircularProgress extends StatelessWidget {
  final double value;
  final Color? color;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const AppCircularProgress({
    super.key,
    required this.value,
    this.color,
    this.size = 60,
    this.strokeWidth = 6,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size, height: size,
            child: CircularProgressIndicator(
              value: value,
              backgroundColor: barColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              strokeWidth: strokeWidth,
            ),
          ),
          if (child != null) child!,
          if (child == null)
            Text('${(value * 100).toInt()}%', style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.bold,
              color: barColor,
            )),
        ],
      ),
    );
  }
}
