import 'package:flutter/material.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/ui/ui_helper.dart';
import 'package:course_users/components/app_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;
  final String? trend;
  final bool trendUp;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
    this.trend,
    this.trendUp = true,
    this.subtitle,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: padding ?? AppPad.a16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trendUp ? Colors.black87 : Colors.red).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: trendUp ? Colors.black87 : Colors.red,
                        size: 14,
                      ),
                      Gap.w4,
                      Text(trend!, style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: trendUp ? Colors.black87 : Colors.red,
                      )),
                    ],
                  ),
                ),
            ],
          ),
          Gap.h16,
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          Gap.h4,
          Text(label, style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          )),
          if (subtitle != null) Gap.h4,
          if (subtitle != null)
            Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(
              color: color, fontWeight: FontWeight.w500,
            )),
          if (progress != null) ...[
            Gap.h12,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
