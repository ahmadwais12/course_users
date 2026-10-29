import 'package:flutter/material.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';

Future<bool> showSignOutDialog(BuildContext context, [Object? _]) async {
  final shouldSignOut = await showAdaptiveAlert<bool>(
    context: context,
    title: 'Sign out',
    message: 'Are you sure you want to sign out?',
    confirmLabel: 'Sign out',
    cancelLabel: 'Cancel',
    isDestructive: true,
  );
  return shouldSignOut ?? false;
}
