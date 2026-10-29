import 'package:flutter/material.dart';
import 'package:course_users/ui/ui_helper.dart';
import 'package:course_users/theme.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool selected;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? chipColor.withValues(alpha: 0.15)
            : chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: chipColor.withValues(alpha: selected ? 0.3 : 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: chipColor),
            Gap.w4,
          ],
          Text(label, style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: chipColor,
          )),
        ],
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final double size;

  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.error;

    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
