import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/providers/settings_provider.dart';
import 'package:course_users/nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    bool? hasSeenOnboarding = ref.read(onboardingStatusProvider);

    int retry = 0;
    while (hasSeenOnboarding == null && retry < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      hasSeenOnboarding = ref.read(onboardingStatusProvider);
      retry++;
    }
    hasSeenOnboarding ??= false;

    if (!hasSeenOnboarding) {
      context.go(AppRoutes.onboarding);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    if (user != null) {
      final role = user.userMetadata?['role']?.toString().toLowerCase();

      switch (role) {
        case 'student':
          context.go(AppRoutes.studentPanel);
          break;
        case 'parent':
          context.go(AppRoutes.parentPanel);
          break;
        default:
          context.go(AppRoutes.home);
      }
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.darkBackground
              : AppGradients.lightBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            isDark
                                ? 'assets/logo/dreamflow-icon-filled-256.png'
                                : 'assets/logo/dreamflow-icon-black.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'DreamFlow',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  AppLocalizations.translate(LSplash.developedBy, locale),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
