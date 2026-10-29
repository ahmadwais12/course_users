import 'package:flutter/material.dart';
import 'package:course_users/ui/ui_helper.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final Widget? action;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.message,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppPad.a24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppPad.a20,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            ),
            Gap.h20,
            Text(message, textAlign: TextAlign.center, style: AppText.h4(ctx: context).copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )),
            if (subtitle != null) Gap.h8,
            if (subtitle != null)
              Text(subtitle!, textAlign: TextAlign.center, style: AppText.bodySm(ctx: context)),
            if (action != null) Gap.h20,
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
