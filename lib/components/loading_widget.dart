import 'package:flutter/material.dart';
import 'package:course_users/ui/ui_helper.dart';
import 'package:course_users/components/dual_ring_spinner.dart';
import 'package:course_users/components/skeleton_widgets.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final Widget? child;
  final bool dualRing;

  const AppLoading({
    super.key,
    this.message,
    this.child,
    this.dualRing = false,
  });

  factory AppLoading.shimmer() => AppLoading(child: const SkeletonParagraph(lines: 5));
  factory AppLoading.shimmerCard() => AppLoading(child: const SkeletonCard());
  factory AppLoading.shimmerList() => AppLoading(child: SkeletonList(itemCount: 5));
  factory AppLoading.shimmerDetail() => AppLoading(child: const SkeletonDetailPage());
  factory AppLoading.shimmerDashboard() => AppLoading(child: const SkeletonDashboard());
  factory AppLoading.shimmerForm() => AppLoading(child: const SkeletonForm());

  @override
  Widget build(BuildContext context) {
    if (child != null) return child!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dualRing)
            const DualRingSpinner()
          else
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
          if (message != null) Gap.h16,
          if (message != null)
            Text(message!, style: AppText.bodySm(ctx: context)),
        ],
      ),
    );
  }
}
