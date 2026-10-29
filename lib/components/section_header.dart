import 'package:flutter/material.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/ui/ui_helper.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;
  final Color? iconColor;
  final bool accentDot;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
    this.iconColor,
    this.accentDot = false,
    this.titleStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = this.padding ?? EdgeInsets.zero;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (accentDot)
            Container(
              width: 12, height: 12,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          if (accentDot) Gap.w12,
          if (icon != null)
            Container(
              width: 36, height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 20),
            ),
          if (icon != null) Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle ?? theme.textTheme.titleLarge),
                if (subtitle != null) Gap.h4,
                if (subtitle != null)
                  Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  )),
              ],
            ),
          ),
          if (action != null) Gap.w8,
          if (action != null) action!,
        ],
      ),
    );
  }
}
