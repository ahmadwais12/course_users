import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform helpers for iOS vs Android adaptive UX (2026 guide).
class PlatformAdaptive {
  PlatformAdaptive._();

  static bool get isApple {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static ScrollPhysics scrollPhysics([ScrollPhysics? parent]) {
    if (isApple) {
      return BouncingScrollPhysics(parent: parent);
    }
    return ClampingScrollPhysics(parent: parent);
  }

  static bool get showFab => !isIOS;

  static Future<void> lightHaptic() => HapticFeedback.lightImpact();
}

class AdaptiveProgress extends StatelessWidget {
  final double? value;
  final Color? color;

  const AdaptiveProgress({super.key, this.value, this.color});

  @override
  Widget build(BuildContext context) {
    if (PlatformAdaptive.isApple) {
      return CupertinoActivityIndicator(color: color);
    }
    return CircularProgressIndicator(value: value, color: color);
  }
}

class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformAdaptive.isApple) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor ?? Theme.of(context).colorScheme.primary,
      );
    }
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeColor,
    );
  }
}

Future<T?> showAdaptiveAlert<T>({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'OK',
  String? cancelLabel,
  VoidCallback? onConfirm,
  bool isDestructive = false,
}) {
  if (PlatformAdaptive.isApple) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          if (cancelLabel != null)
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false as T?),
              child: Text(cancelLabel),
            ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            isDefaultAction: !isDestructive,
            onPressed: () {
              Navigator.of(ctx).pop(true as T?);
              onConfirm?.call();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false as T?),
            child: Text(cancelLabel),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop(true as T?);
            onConfirm?.call();
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  final initial = initialDate ?? now;
  final first = firstDate ?? DateTime(now.year - 50);
  final last = lastDate ?? DateTime(now.year + 50);

  if (PlatformAdaptive.isApple) {
    DateTime temp = initial;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(temp),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: first,
                maximumDate: last,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: last,
  );
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool centerTitle;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformAdaptive.isApple) {
      return PreferredSize(
        preferredSize: preferredSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              middle: Text(title),
              leading: leading ??
                  (showBackButton && Navigator.of(context).canPop()
                      ? CupertinoNavigationBarBackButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                        )
                      : null),
              trailing: actions == null || actions!.isEmpty
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
              backgroundColor: backgroundColor ??
                  CupertinoTheme.of(context).barBackgroundColor,
              border: const Border(
                bottom: BorderSide(color: Color(0x4C000000), width: 0.5),
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      );
    }

    return AppBar(
      title: Text(title),
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      bottom: bottom,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class AdaptiveScaffold extends StatelessWidget {
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool safeArea;
  final bool resizeToAvoidBottomInset;

  const AdaptiveScaffold({
    super.key,
    this.title,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.safeArea = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final fab = PlatformAdaptive.showFab ? floatingActionButton : null;
    final mergedActions = <Widget>[
      ...?actions,
      if (!PlatformAdaptive.showFab && floatingActionButton != null)
        IconButton(
          tooltip: 'Add',
          icon: const Icon(CupertinoIcons.add),
          onPressed: () {
            final child = floatingActionButton;
            if (child is FloatingActionButton && child.onPressed != null) {
              PlatformAdaptive.lightHaptic();
              child.onPressed!();
            }
          },
        ),
    ];

    final effectiveBar = appBar ??
        (title == null
            ? null
            : AdaptiveAppBar(title: title!, actions: mergedActions));

    Widget content = body;
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: effectiveBar,
      body: content,
      floatingActionButton: fab,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

class AdaptiveBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AdaptiveBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformAdaptive.isApple) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: (i) {
          PlatformAdaptive.lightHaptic();
          onTap(i);
        },
        items: items,
      );
    }
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: items
          .map(
            (e) => NavigationDestination(
              icon: e.icon,
              selectedIcon: e.activeIcon,
              label: e.label ?? '',
            ),
          )
          .toList(),
    );
  }
}

class AdaptiveRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const AdaptiveRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

bool get isRunningOnIOSDevice {
  if (kIsWeb) return false;
  try {
    return Platform.isIOS;
  } catch (_) {
    return false;
  }
}
