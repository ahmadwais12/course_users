import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';
import 'package:course_users/providers/settings_provider.dart';
import 'package:course_users/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingStatusProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go('/home');
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/logo/dreamflow-icon-filled-256.png'
        : 'assets/logo/dreamflow-icon-black.png';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.darkBackground : AppGradients.lightBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  children: [
                    _IntroStep(
                      logoAsset: logoAsset,
                      appName: AppLocalizations.translate(L.appName, locale),
                      bgColor: theme.colorScheme.surface.withValues(alpha: 0.16),
                      fgColor: theme.colorScheme.onSurface,
                    ),
                    _StepContainer(
                      title: AppLocalizations.translate(L.selectLanguage, locale),
                      subtitle: 'Choose your preferred app language',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _ChoicePill(
                            label: 'English',
                            selected: locale == 'en',
                            onTap: () => ref.read(localeProvider.notifier).state = 'en',
                          ),
                          _ChoicePill(
                            label: 'پښتو',
                            selected: locale == 'ps',
                            onTap: () => ref.read(localeProvider.notifier).state = 'ps',
                          ),
                          _ChoicePill(
                            label: 'فارسی',
                            selected: locale == 'fa',
                            onTap: () => ref.read(localeProvider.notifier).state = 'fa',
                          ),
                        ],
                      ),
                    ),
                    _StepContainer(
                      title: AppLocalizations.translate(L.themeMode, locale),
                      subtitle: 'Pick the look that feels best to you',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _ChoicePill(
                            label: 'Light',
                            icon: Icons.light_mode_outlined,
                            selected: themeMode == ThemeMode.light,
                            onTap: () =>
                                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                          ),
                          _ChoicePill(
                            label: 'Dark',
                            icon: Icons.dark_mode_outlined,
                            selected: themeMode == ThemeMode.dark,
                            onTap: () =>
                                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                          ),
                          _ChoicePill(
                            label: 'System',
                            icon: Icons.brightness_auto_outlined,
                            selected: themeMode == ThemeMode.system,
                            onTap: () =>
                                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingXl,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            width: _currentPage == index ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: _currentPage == index ? 0.9 : 0.35,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_currentPage > 0) ...[
                      OutlinedButton(
                        onPressed: _previousPage,
                        child: Text(
                          AppLocalizations.translate(L.back, locale),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage == 0
                                ? AppLocalizations.translate(L.welcome, locale)
                                : AppLocalizations.translate(L.continue_, locale),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({
    required this.logoAsset,
    required this.appName,
    required this.bgColor,
    required this.fgColor,
  });

  final String logoAsset;
  final String appName;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  logoAsset,
                  width: 132,
                  height: 132,
                  fit: BoxFit.contain,
                ),
                Text(
                  appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepContainer extends StatelessWidget {
  const _StepContainer({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.82);
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: fg,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.10),
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary
            : theme.dividerColor,
      ),
    );
  }
}
