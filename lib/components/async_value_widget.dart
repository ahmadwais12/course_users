import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/components/dual_ring_spinner.dart';
import 'package:course_users/components/empty_state.dart';
import 'package:course_users/components/error_widget.dart' as cmp_err;
import 'package:course_users/components/skeleton_widgets.dart';

/// Displays an [AsyncValue] with loading/error/data states.
/// Set [shimmer] to true for skeleton shimmer placeholders during loading.
/// Use [skeleton] to provide a custom skeleton widget; defaults to [SkeletonDashboard].
class AsyncWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? stack)? error;
  final bool shimmer;
  final Widget? skeleton;

  const AsyncWidget({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
    this.error,
    this.shimmer = false,
    this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => loading ?? (shimmer
          ? (skeleton ?? const SkeletonDashboard())
          : const Center(child: DualRingSpinner())),
      error: (err, stack) => error?.call(err, stack) ?? cmp_err.AppErrorWidget(
        message: err.toString(),
        onRetry: null,
      ),
    );
  }
}

/// Displays a [Future] with loading/error/data states.
/// Set [shimmer] to true for skeleton shimmer placeholders during loading.
class FutureWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final Widget? loading;
  final Widget Function(Object error)? error;
  final Widget? empty;
  final bool shimmer;
  final Widget? skeleton;

  const FutureWidget({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.error,
    this.empty,
    this.shimmer = false,
    this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? (shimmer
              ? (skeleton ?? const SkeletonDashboard())
              : const Center(child: DualRingSpinner()));
        }
        if (snapshot.hasError) {
          return error?.call(snapshot.error!) ?? cmp_err.AppErrorWidget(
            message: snapshot.error.toString(),
            onRetry: null,
          );
        }
        final data = snapshot.data;
        if (data == null || (data is List && data.isEmpty)) {
          return empty ?? const AppEmptyState(message: 'No data available');
        }
        return builder(data);
      },
    );
  }
}
