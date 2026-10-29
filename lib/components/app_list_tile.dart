import 'package:flutter/material.dart';
import 'package:course_users/ui/ui_helper.dart';

class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingColor,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.contentPadding,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileContent = Row(
      children: [
        if (leading != null)
          leading!
        else if (leadingIcon != null)
          Container(
            width: dense ? 32 : 40,
            height: dense ? 32 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (leadingColor ?? theme.colorScheme.primary).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(dense ? 8 : 12),
            ),
            child: Icon(
              leadingIcon,
              color: leadingColor ?? theme.colorScheme.primary,
              size: dense ? 16 : 20,
            ),
          ),
        if (leading != null || leadingIcon != null) Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(
                fontSize: dense ? 13 : 14,
                fontWeight: FontWeight.w600,
              )),
              if (subtitle != null) const SizedBox(height: 2),
              if (subtitle != null)
                Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
            ],
          ),
        ),
        if (trailing != null) Gap.w8,
        if (trailing != null) trailing!,
      ],
    );

    final effectivePadding = padding ?? (dense ? AppPad.v8 : AppPad.v12);

    if (onTap != null) {
      return Padding(
        padding: effectivePadding,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: contentPadding ?? AppPad.h8,
              child: tileContent,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: Padding(
        padding: contentPadding ?? EdgeInsets.zero,
        child: tileContent,
      ),
    );
  }
}
