import 'package:flutter/material.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/ui/ui_helper.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final Color? color;
  final LinearGradient? gradient;
  final bool glass;
  final bool elevated;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.color,
    this.gradient,
    this.glass = false,
    this.elevated = false,
    this.borderRadius,
    this.margin,
    this.onTap,
    this.onLongPress,
  });

  factory AppCard.gradient({
    required Widget child,
    required Color start,
    required Color end,
    bool vertical = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) =>
      AppCard(
        padding: padding,
        margin: margin,
        onTap: onTap,
        gradient: LinearGradient(
          begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
          end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [start, end],
        ),
        child: child,
      );

  factory AppCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) =>
      AppCard(padding: padding, margin: margin, onTap: onTap, glass: true, child: child);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? AppPad.a16;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.md);
    final effectiveMargin = margin ?? EdgeInsets.zero;

    Widget card = Container(
      height: height,
      width: width,
      padding: effectivePadding,
      margin: effectiveMargin,
      decoration: _buildDecoration(theme, effectiveRadius),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: card,
        ),
      );
    }

    return card;
  }

  BoxDecoration _buildDecoration(ThemeData theme, BorderRadius radius) {
    if (glass) {
      return BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: radius,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      );
    }
    if (gradient != null) {
      return BoxDecoration(
        gradient: gradient,
        borderRadius: radius,
      );
    }
    if (elevated) {
      return BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: radius,
        boxShadow: [AppShadows.medium(theme.shadowColor)],
      );
    }
    return BoxDecoration(
      color: color ?? theme.colorScheme.surface,
      borderRadius: radius,
      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      boxShadow: [AppShadows.soft(theme.shadowColor)],
    );
  }
}
