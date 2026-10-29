import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/nav.dart';
import 'package:course_users/providers/home_provider.dart';
import 'package:course_users/providers/social_provider.dart';
import 'package:course_users/providers/auth_provider.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';
import 'package:course_users/widgets/motion.dart';
import 'package:course_users/widgets/insight_ui.dart';
import 'package:course_users/widgets/dashboard_components.dart';
import 'package:course_users/widgets/ad_banner_widget.dart';
import 'package:course_users/components/components.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:course_users/screens/our_story_screen.dart';
import 'package:course_users/screens/home_menu_screens.dart';
import 'package:course_users/screens/english_test_screen.dart';
import 'package:course_users/screens/home_menu_screens_part2.dart';
import 'package:course_users/widgets/skeleton_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:course_users/panels/student/student_panel_screen.dart';
import 'package:course_users/panels/parent/parent_panel_screen.dart';
import 'package:course_users/screens/chat_screen.dart';
import 'package:course_users/screens/notifications_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _navIndex = 2;
  int _studentNavIndex = 0;
  int _parentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final role = user?.userMetadata?['role']?.toString().toLowerCase() ?? '';

    if (isAuth && role == 'student') {
      return _buildStudentNav(context, theme, locale);
    }
    if (isAuth && role == 'parent') {
      return _buildParentNav(context, theme, locale);
    }

    return _buildPublicNav(context, theme, locale);
  }

  Widget _buildPublicNav(BuildContext context, ThemeData theme, String locale) {
    final featuresAsync = ref.watch(featuresProvider);
    final statsAsync = ref.watch(homeStatsProvider);
    final testimonialsAsync = ref.watch(testimonialsProvider);
    final isLoading = featuresAsync.isLoading ||
        statsAsync.isLoading ||
        testimonialsAsync.isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 72 + MediaQuery.of(context).padding.bottom,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: NavigationBar(
                selectedIndex: _navIndex,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600);
                  }
                  return const TextStyle(fontSize: 10);
                }),
                onDestinationSelected: (i) {
                  setState(() => _navIndex = i);
                  if (i == 2) return;
                  switch (i) {
                    case 0:
                      context.go(AppRoutes.courses);
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactCourseScreen()),
                      );
                      break;
                    case 3:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MenuScreen(locale: locale)),
                      );
                      break;
                  }
                },
                height: 72,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: AppLocalizations.translate(LHome.courses, locale),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.contact_mail_outlined),
                    selectedIcon: Icon(Icons.contact_mail_rounded),
                    label: AppLocalizations.translate(LHome.contact, locale),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: AppLocalizations.translate(L.home, locale),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_rounded),
                    label: AppLocalizations.translate(LHome.menu, locale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      theme.scaffoldBackgroundColor,
                      theme.colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(top: -80, right: -60, child: _Glow(size: 280)),
            const Positioned(bottom: -40, left: -50, child: _Glow(size: 240)),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const _HomeAppBar(),
                if (isLoading)
                  const SliverFillRemaining(
                    child: DashboardSkeleton(),
                  )
                else
                  SliverToBoxAdapter(
                    child: Column(
                      children: const [
                        _HeroSection(),
                        _EnhancedDashboardSection(),
                        _FeaturePreviewSection(),
                        _StatsSection(),
                        _TopStudentsSection(),
                        _OurTeachersSection(),
                        _StorySection(),
                        _QuickLinksSlider(),
                        _BranchesSection(),
                        _VisionSection(),
                        _TestimonialsSection(),
                        _QuickActionsSection(),
                        _Footer(),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentNav(BuildContext context, ThemeData theme, String locale) {
    final pages = <Widget>[
      const StudentPanelScreen(),
      const SizedBox.shrink(),
      const ChatScreen(),
      MenuScreen(locale: locale),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.translate(L.notifications, locale)), centerTitle: true),
              body: const NotificationsScreen(),
            )),
          ),
        ),
        title: Image.asset(
          theme.brightness == Brightness.dark
              ? 'assets/logo/dreamflow-icon-filled-256.png'
              : 'assets/logo/dreamflow-icon-black.png',
          width: 72,
          height: 72,
          errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome_rounded),
        ),
        centerTitle: true,
      ),
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 72 + MediaQuery.of(context).padding.bottom,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _studentNavIndex,
            onDestinationSelected: (i) {
              if (i == 1) {
                context.go(AppRoutes.home);
                return;
              }
              setState(() => _studentNavIndex = i);
            },
            height: 72,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: AppLocalizations.translate(L.dashboard, locale),
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: AppLocalizations.translate(L.home, locale),
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                selectedIcon: Icon(Icons.chat_rounded),
                label: AppLocalizations.translate(LHome.chat, locale),
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_rounded),
                label: AppLocalizations.translate(LHome.menu, locale),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _studentNavIndex,
        children: pages,
      ),
    );
  }

  Widget _buildParentNav(BuildContext context, ThemeData theme, String locale) {
    final pages = <Widget>[
      const ParentPanelScreen(),
      const SizedBox.shrink(),
      const ChatScreen(),
      MenuScreen(locale: locale),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.translate(L.notifications, locale)), centerTitle: true),
              body: const NotificationsScreen(),
            )),
          ),
        ),
        title: Image.asset(
          theme.brightness == Brightness.dark
              ? 'assets/logo/dreamflow-icon-filled-256.png'
              : 'assets/logo/dreamflow-icon-black.png',
          width: 72,
          height: 72,
          errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome_rounded),
        ),
        centerTitle: true,
      ),
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 72 + MediaQuery.of(context).padding.bottom,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _parentNavIndex,
            onDestinationSelected: (i) {
              if (i == 1) {
                context.go(AppRoutes.home);
                return;
              }
              setState(() => _parentNavIndex = i);
            },
            height: 72,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: AppLocalizations.translate(L.dashboard, locale),
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: AppLocalizations.translate(L.home, locale),
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                selectedIcon: Icon(Icons.chat_rounded),
                label: AppLocalizations.translate(LHome.chat, locale),
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_rounded),
                label: AppLocalizations.translate(LHome.menu, locale),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _parentNavIndex,
        children: pages,
      ),
    );
  }
}

class _HomeAppBar extends ConsumerWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Image.asset(
        isDark
            ? 'assets/logo/dreamflow-icon-filled-256.png'
            : 'assets/logo/dreamflow-icon-black.png',
        width: 72,
        height: 72,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.auto_awesome_rounded),
      ),
      actions: [
        const SizedBox(width: 8),
        // Language Selector
        PopupMenuButton<String>(
          icon: const Icon(Icons.language_rounded),
          tooltip: AppLocalizations.translate('select_language', locale),
          onSelected: (lang) => ref.read(localeProvider.notifier).state = lang,
          itemBuilder: (context) => [
            PopupMenuItem(
                value: 'en',
                child: Text(AppLocalizations.translate(LHome.languageEnglish, locale))),
            PopupMenuItem(
                value: 'ps',
                child: Text(AppLocalizations.translate(LHome.languagePashto, locale))),
            PopupMenuItem(
                value: 'fa',
                child:
                    Text(AppLocalizations.translate(LHome.languageDari, locale))),
          ],
        ),
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          onPressed: () {
            ref.read(themeModeProvider.notifier).setThemeMode(
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                );
          },
        ),
        // Profile/More Button
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
          tooltip: AppLocalizations.translate('profile', locale),
          onSelected: (value) => _handleMoreSelection(context, value),
          itemBuilder: (context) => [
            // Profile Section
            PopupMenuItem<String>(
              enabled: false,
              height: 60,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.translate(LHome.guestUser, locale),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppLocalizations.translate(LHome.tapToLogin, locale),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // Login Option
            PopupMenuItem(
              value: 'login',
              child: ListTile(
                leading: const Icon(Icons.login_rounded),
                title: Text(AppLocalizations.translate('login', locale)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMoreSelection(BuildContext context, String value) {
    if (value == 'login') {
      context.go(AppRoutes.login);
      return;
    }
    _handleMenuSelection(context, value);
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'our_story':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OurStoryScreen()),
        );
        break;
      case 'our_courses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OurCoursesScreen()),
        );
        break;
      case 'our_branches':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OurBranchesScreen()),
        );
        break;
      case 'new_classes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OurNewClassesScreen()),
        );
        break;
      case 'test_english':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EnglishTestScreen()),
        );
        break;
      case 'apply_online':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ApplyOnlineScreen()),
        );
        break;
      case 'request_call':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestCallScreen()),
        );
        break;
      case 'why_course':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WhyOurCourseScreen()),
        );
        break;
      case 'reviews':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OurReviewsScreen()),
        );
        break;
      case 'contact':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactCourseScreen()),
        );
        break;
    }
  }
}

class _HeroSection extends ConsumerWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 56),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeSlide(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppLocalizations.translate('home_tagline', locale),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeSlide(
                delay: const Duration(milliseconds: 100),
                child: SizedBox(
                  width: double.infinity,
                  child: SizedBox(
                    height: 85,
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          AppLocalizations.translate('home_heading', locale),
                          textAlign: TextAlign.center,
                          textStyle: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -2,
                            color: theme.colorScheme.onSurface,
                          ),
                          speed: const Duration(milliseconds: 40),
                          cursor: '',
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FadeSlide(
                delay: const Duration(milliseconds: 180),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: AppFadingText(
                    texts: [
                      AppLocalizations.translate('home_subtitle_1', locale),
                      AppLocalizations.translate('home_subtitle_2', locale),
                      AppLocalizations.translate('home_subtitle_3', locale),
                    ],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    duration: const Duration(seconds: 4),
                    height: 110,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeSlide(
                delay: const Duration(milliseconds: 260),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment:
                      compact ? WrapAlignment.center : WrapAlignment.start,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: Text(
                          AppLocalizations.translate('home_start_now', locale)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.mobileHome),
                      icon: const Icon(Icons.phone_android_rounded),
                      label: Text(AppLocalizations.translate(
                          'home_preview_mobile', locale)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FadeSlide(
                delay: const Duration(milliseconds: 320),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    InsightStatChip(
                        label: AppLocalizations.translate(
                            'home_live_dashboards', locale),
                        value: '24+'),
                    InsightStatChip(
                        label:
                            AppLocalizations.translate('home_modules', locale),
                        value: 'All in one'),
                    InsightStatChip(
                        label: AppLocalizations.translate(
                            'home_responsive', locale),
                        value: 'Mobile + Web'),
                  ],
                ),
              ),
            ],
          );

          final preview = const FadeSlide(
            delay: Duration(milliseconds: 220),
            child: _DashboardPreview(),
          );

          if (compact) {
            return Column(
              children: [
                intro,
                const SizedBox(height: 28),
                preview,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 11, child: intro),
              const SizedBox(width: 28),
              Expanded(flex: 10, child: preview),
            ],
          );
        },
      ),
    );
  }
}

class _FeaturePreviewSection extends ConsumerWidget {
  const _FeaturePreviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final featuresAsync = ref.watch(featuresProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate('home_designed_for_institute', locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.translate('home_design_subtitle', locale),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 32),
          // Feature Cards Slider
          featuresAsync.when(
            data: (features) {
              if (features.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    final cardWidth =
                        (MediaQuery.of(context).size.width - 48) * 0.85;
                    return Container(
                      width: cardWidth.clamp(240, 320),
                      margin: EdgeInsets.only(
                        right: index < features.length - 1 ? 20 : 0,
                      ),
                      child: _FeatureCard(
                        data: _FeatureData(
                          icon: _getIconData(
                              feature['icon_name'] as String? ?? 'star'),
                          title: feature['title'] as String,
                          desc: feature['description'] as String? ?? '',
                          color: _hexToColor(
                              feature['color_hex'] as String? ?? '#2196F3'),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 320,
                  margin: EdgeInsets.only(
                    right: index < 2 ? 20 : 0,
                  ),
                  child: const SkeletonCard(),
                ),
              ),
            ),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology;
      case 'school':
        return Icons.school;
      case 'schedule':
        return Icons.schedule;
      case 'analytics':
        return Icons.analytics;
      case 'play_circle':
        return Icons.play_circle;
      case 'groups':
        return Icons.groups;
      default:
        return Icons.star;
    }
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xff')));
    } catch (e) {
      return Colors.black87;
    }
  }
}

class _DashboardPreview extends ConsumerWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _WindowDot(Colors.redAccent),
              const SizedBox(width: 6),
              const _WindowDot(Colors.orangeAccent),
              const SizedBox(width: 6),
              const _WindowDot(Colors.black87),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${AppLocalizations.translate(L.appName, locale)}${AppLocalizations.translate(LHome.dashboardSuffix, locale)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: InsightMetricCard(
                  label: AppLocalizations.translate('home_students', locale),
                  value: '1,248',
                  trend: '+8%',
                  icon: Icons.groups_outlined,
                  accent: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InsightMetricCard(
                  label:
                      AppLocalizations.translate('home_revenue_card', locale),
                  value: 'PKR 2.4M',
                  trend: '+11%',
                  icon: Icons.payments_outlined,
                  accent: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InsightLineChartCard(
            title: AppLocalizations.translate('home_weekly_momentum', locale),
            subtitle:
                AppLocalizations.translate('home_momentum_subtitle', locale),
            points: [
              InsightPoint('Mon', 22),
              InsightPoint('Tue', 28),
              InsightPoint('Wed', 26),
              InsightPoint('Thu', 34),
              InsightPoint('Fri', 38),
            ],
            accent: Colors.black87,
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final statsAsync = ref.watch(homeStatsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
      child: statsAsync.when(
        data: (stats) {
          return Wrap(
            spacing: 52,
            runSpacing: 36,
            alignment: WrapAlignment.center,
            children: [
              _BigStat(
                value: '${stats.totalSchools}+',
                label: AppLocalizations.translate(
                    'home_active_institutes', locale),
              ),
              _BigStat(
                value: '${stats.totalStudents}',
                label:
                    AppLocalizations.translate('home_total_students', locale),
              ),
              _BigStat(
                value: '${stats.totalTeachers}',
                label:
                    AppLocalizations.translate('home_expert_teachers', locale),
              ),
              _BigStat(
                value: '${stats.totalClasses}',
                label:
                    AppLocalizations.translate('home_active_classes', locale),
              ),
            ],
          );
        },
        loading: () => Wrap(
          spacing: 52,
          runSpacing: 36,
          alignment: WrapAlignment.center,
          children: List.generate(
              4,
              (_) => const SizedBox(
                    width: 160,
                    child: Column(
                      children: [
                        SkeletonLine(width: 80, height: 36),
                        SizedBox(height: 12),
                        SkeletonLine(width: 100, height: 16),
                      ],
                    ),
                  )),
        ),
        error: (error, stack) => Wrap(
          spacing: 52,
          runSpacing: 36,
          alignment: WrapAlignment.center,
          children: [
            _BigStat(
                value: '500+',
                label: AppLocalizations.translate(
                    'home_active_institutes', locale)),
            _BigStat(
                value: '50k+',
                label: AppLocalizations.translate(
                    'home_daily_active_students', locale)),
            _BigStat(
                value: '99.9%',
                label:
                    AppLocalizations.translate('home_platform_uptime', locale)),
            _BigStat(
                value: '24/7',
                label: AppLocalizations.translate('home_support_247', locale)),
          ],
        ),
      ),
    );
  }
}

class _TestimonialsSection extends ConsumerStatefulWidget {
  const _TestimonialsSection();

  @override
  ConsumerState<_TestimonialsSection> createState() =>
      _TestimonialsSectionState();
}

class _TestimonialsSectionState extends ConsumerState<_TestimonialsSection> {
  final _pageController = PageController(viewportFraction: 0.85);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final state = ref.read(testimonialsProvider);
      final testimonials = state.valueOrNull ?? [];
      if (testimonials.isEmpty) return;
      final next = (_pageController.page?.toInt() ?? 0) + 1;
      if (next >= testimonials.length) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final testimonialsAsync = ref.watch(testimonialsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate('home_trusted_by_educators', locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 28),
          testimonialsAsync.when(
            data: (testimonials) {
              if (testimonials.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: testimonials.length,
                  itemBuilder: (context, index) {
                    final t = testimonials[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.format_quote,
                                  size: 32,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  '"${t['quote'] as String}"',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t['author'] as String? ?? '',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (t['author_title'] != null)
                                Text(
                                  t['author_title'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Column(
              children: [
                SkeletonCard(
                  child: Column(
                    children: [
                      SkeletonLine(width: double.infinity, height: 14),
                      SizedBox(height: 8),
                      SkeletonLine(width: double.infinity, height: 14),
                      SizedBox(height: 8),
                      SkeletonLine(width: 140, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            error: (error, stack) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: InsightPromoBanner(
                title: AppLocalizations.translate(
                    'home_testimonial_fallback', locale),
                subtitle: AppLocalizations.translate(
                    'home_testimonial_fallback_sub', locale),
                ctaLabel: AppLocalizations.translate('home_watch_demo', locale),
                accent: Colors.black87,
                icon: Icons.format_quote_rounded,
                onTap: () => context.go(AppRoutes.mobileHome),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinksSlider extends ConsumerStatefulWidget {
  const _QuickLinksSlider();

  @override
  ConsumerState<_QuickLinksSlider> createState() => _QuickLinksSliderState();
}

class _QuickLinksSliderState extends ConsumerState<_QuickLinksSlider> {
  final _pageController = PageController(viewportFraction: 0.7);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final items = 5;
      if (items == 0) return;
      final next = (_pageController.page?.toInt() ?? 0) + 1;
      if (next >= items) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<_QuickLinkData> _quickLinks(String locale) => [
    _QuickLinkData(Icons.person_rounded, AppLocalizations.translate(LHome.quickMyAccount, locale), 'settings'),
    _QuickLinkData(Icons.auto_stories_rounded, AppLocalizations.translate(LHome.quickWhoWeAre, locale), 'our_story'),
    _QuickLinkData(Icons.event_available_rounded, AppLocalizations.translate(LHome.quickOurNewClasses, locale), 'new_classes'),
    _QuickLinkData(Icons.business_rounded, AppLocalizations.translate(LHome.quickBranches, locale), 'branches'),
    _QuickLinkData(Icons.emoji_events_rounded, AppLocalizations.translate(LHome.quickWhyDreamflow, locale), 'why_course'),
  ];

  void _handleTap(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        context.go(AppRoutes.settings);
        break;
      case 'our_story':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const OurStoryScreen()));
        break;
      case 'new_classes':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OurNewClassesScreen()));
        break;
      case 'branches':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OurBranchesScreen()));
        break;
      case 'why_course':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WhyOurCourseScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final links = _quickLinks(locale);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: links.length,
              itemBuilder: (context, index) {
                final item = links[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _handleTap(context, item.action),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.08),
                              theme.colorScheme.secondary
                                  .withValues(alpha: 0.04),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon,
                                size: 40, color: theme.colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkData {
  final IconData icon;
  final String label;
  final String action;

  const _QuickLinkData(this.icon, this.label, this.action);
}

class _StorySection extends ConsumerStatefulWidget {
  const _StorySection();

  @override
  ConsumerState<_StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends ConsumerState<_StorySection> {
  Future<List<Map<String, dynamic>>>? _milestonesFuture;

  @override
  void initState() {
    super.initState();
    _milestonesFuture = _fetchStoryMilestones();
  }

  Future<List<Map<String, dynamic>>> _fetchStoryMilestones() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('home_hero_sections')
          .select()
          .eq('is_active', true)
          .order('display_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.04),
            theme.colorScheme.secondary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate(LHome.menuOurStory, locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.translate(LHome.storyDesc, locale),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _milestonesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SkeletonList(itemCount: 2);
              }
              final milestones = snapshot.data ?? [];
              if (milestones.isEmpty) {
                return const SizedBox.shrink();
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: milestones.map((m) {
                      return _buildMilestone(
                        context,
                        m['title'] as String? ?? '',
                        m['subtitle'] as String? ?? '',
                        m['description'] as String? ?? '',
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone(
      BuildContext context, String year, String title, String desc) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                year,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchesSection extends ConsumerWidget {
  const _BranchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final branchesAsync = ref.watch(activeBranchesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate(LHome.menuOurBranches, locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.translate(LHome.branchesSub, locale),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 32),
          branchesAsync.when(
            data: (branches) {
              if (branches.isEmpty) return const SizedBox.shrink();
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 600;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: branches.map((b) {
                      return SizedBox(
                        width: isCompact ? double.infinity : 260,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _branchIcon(
                                      b['is_headquarters'] == true
                                          ? 'main'
                                          : ''),
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b['name'] as String? ?? '',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      b['address'] as String? ?? '',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      b['city'] as String? ??
                                          b['province'] as String? ??
                                          '',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

IconData _branchIcon(String type) {
  switch (type) {
    case 'main':
      return Icons.location_city;
    case 'north':
      return Icons.business;
    case 'south':
      return Icons.apartment;
    default:
      return Icons.store;
  }
}

class _VisionSection extends ConsumerWidget {
  const _VisionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate(LHome.visionTitle, locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 768;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _VisionCard(
                    icon: Icons.lightbulb_outline,
                    title: AppLocalizations.translate(LHome.visionInnovation, locale),
                    desc: AppLocalizations.translate(LHome.visionInnovationDesc, locale),
                    compact: isCompact,
                  ),
                  _VisionCard(
                    icon: Icons.people_outline,
                    title: AppLocalizations.translate(LHome.visionAccessibility, locale),
                    desc: AppLocalizations.translate(LHome.visionAccessibilityDesc, locale),
                    compact: isCompact,
                  ),
                  _VisionCard(
                    icon: Icons.trending_up,
                    title: AppLocalizations.translate(LHome.visionExcellence, locale),
                    desc: AppLocalizations.translate(LHome.visionExcellenceDesc, locale),
                    compact: isCompact,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool compact;

  const _VisionCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: compact ? double.infinity : 280,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
      ),
      child: Wrap(
        spacing: 48,
        runSpacing: 32,
        alignment: WrapAlignment.spaceBetween,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              return SizedBox(
                width: isCompact ? double.infinity : 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          isDark
                              ? 'assets/logo/dreamflow-icon-filled-256.png'
                              : 'assets/logo/dreamflow-icon-black.png',
                          width: 52,
                          height: 52,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.auto_awesome),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'DreamFlow',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.translate('home_footer_desc', locale),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.64),
                        height: 1.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    const _SocialMediaIcons(),
                  ],
                ),
              );
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              return SizedBox(
                width: isCompact ? double.infinity : 420,
                child: Wrap(
                  spacing: isCompact ? 16 : 32,
                  runSpacing: 24,
                  children: [
                    _FooterLinks(
                      title: AppLocalizations.translate('home_product', locale),
                      links: [
                        AppLocalizations.translate('home_features', locale),
                        AppLocalizations.translate('home_mobile_ui', locale),
                        AppLocalizations.translate('home_reports', locale),
                        AppLocalizations.translate('home_ads', locale),
                      ],
                    ),
                    _FooterLinks(
                      title: AppLocalizations.translate('home_company', locale),
                      links: [
                        AppLocalizations.translate('home_about', locale),
                        AppLocalizations.translate('home_support', locale),
                        AppLocalizations.translate('home_contact', locale),
                        AppLocalizations.translate('home_security', locale),
                      ],
                    ),
                    _FooterLinks(
                      title: AppLocalizations.translate('home_legal', locale),
                      links: [
                        AppLocalizations.translate('home_privacy', locale),
                        AppLocalizations.translate('home_terms', locale),
                        AppLocalizations.translate('home_policy', locale),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            AppLocalizations.translate('home_copyright', locale),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.42),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isHovered
                ? widget.data.color.withValues(alpha: 0.36)
                : theme.dividerColor.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  widget.data.color.withValues(alpha: _isHovered ? 0.12 : 0.05),
              blurRadius: _isHovered ? 30 : 18,
              offset: Offset(0, _isHovered ? 16 : 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(widget.data.icon, color: widget.data.color, size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              widget.data.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.data.desc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterLinks({
    required this.title,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                link,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialMediaIcons extends ConsumerWidget {
  const _SocialMediaIcons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final socialAsync = ref.watch(socialProvider);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: (socialAsync.valueOrNull ?? []).map((social) {
        return Tooltip(
          message: social.platform,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final uri = Uri.tryParse(social.url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                social.icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;

  const _Glow({required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// NEW ENHANCED SECTIONS WITH CHARTS & GRAPHS
// ============================================

class _EnhancedDashboardSection extends ConsumerStatefulWidget {
  const _EnhancedDashboardSection();

  @override
  ConsumerState<_EnhancedDashboardSection> createState() =>
      _EnhancedDashboardSectionState();
}

class _EnhancedDashboardSectionState
    extends ConsumerState<_EnhancedDashboardSection> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    const totalCards = 4;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_currentPage < totalCards - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    final cards = <DashboardStatCard>[
      DashboardStatCard(
        title: AppLocalizations.translate(LDash.totalStudents, locale),
        value: AppLocalizations.translate(LHome.statStudentsVal, locale),
        icon: Icons.people,
        color: Colors.black87,
        subtitle: AppLocalizations.translate(LHome.statStudentsSub, locale),
        percentageChange: 12.5,
      ),
      DashboardStatCard(
        title: AppLocalizations.translate(LDash.activeCourses, locale),
        value: AppLocalizations.translate(LHome.statCoursesVal, locale),
        icon: Icons.school,
        color: Colors.black87,
        subtitle: AppLocalizations.translate(LHome.statCoursesSub, locale),
        percentageChange: 8.3,
      ),
      DashboardStatCard(
        title: AppLocalizations.translate(LHome.completionRate, locale),
        value: AppLocalizations.translate(LHome.statCompletionVal, locale),
        icon: Icons.trending_up,
        color: Colors.orange,
        subtitle: AppLocalizations.translate(LHome.statCompletionSub, locale),
        percentageChange: 5.2,
      ),
      DashboardStatCard(
        title: AppLocalizations.translate(LDash.totalRevenue, locale),
        value: AppLocalizations.translate(LHome.statRevenueVal, locale),
        icon: Icons.attach_money,
        color: Colors.purple,
        subtitle: AppLocalizations.translate(LHome.statRevenueSub, locale),
        percentageChange: 18.7,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.translate(LHome.dashboardOverview, locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.translate(LHome.dashboardSubtitle, locale),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  right: index < cards.length - 1 ? 16 : 0,
                ),
                child: cards[index],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              cards.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStudentsSection extends ConsumerStatefulWidget {
  const _TopStudentsSection();

  @override
  ConsumerState<_TopStudentsSection> createState() =>
      _TopStudentsSectionState();
}

class _TopStudentsSectionState extends ConsumerState<_TopStudentsSection> {
  final _pageController = PageController(viewportFraction: 0.75);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final state = ref.read(topStudentsProvider);
      final students = state.valueOrNull ?? [];
      if (students.isEmpty) return;
      final next = (_pageController.page?.toInt() ?? 0) + 1;
      if (next >= students.length) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final studentsAsync = ref.watch(topStudentsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate(LHome.topStudents, locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.translate(LHome.topStudentsSub, locale),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 28),
          studentsAsync.when(
            data: (students) {
              if (students.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final name = s['full_name'] as String? ?? AppLocalizations.translate(LHome.fallbackStudent, locale);
                    final code = s['student_code'] as String? ?? '';
                    final grade = s['average_grade'] as num? ?? 0;
                    final initial = name.isNotEmpty ? name[0] : '?';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.08),
                                theme.colorScheme.secondary.withValues(alpha: 0.04),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                child: Text(
                                  initial,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                code,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              if (grade > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.translate(LHome.gradeLabel, locale).replaceAll('%s', grade.toStringAsFixed(0)),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 18, color: Colors.amber.shade700),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.translate(LHome.topPerformer, locale),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.bold,
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
                  },
                ),
              );
            },
            loading: () => const SkeletonList(itemCount: 3),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _OurTeachersSection extends ConsumerStatefulWidget {
  const _OurTeachersSection();

  @override
  ConsumerState<_OurTeachersSection> createState() =>
      _OurTeachersSectionState();
}

class _OurTeachersSectionState extends ConsumerState<_OurTeachersSection> {
  final _pageController = PageController(viewportFraction: 0.75);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final state = ref.read(teachersProvider);
      final teachers = state.valueOrNull ?? [];
      if (teachers.isEmpty) return;
      final next = (_pageController.page?.toInt() ?? 0) + 1;
      if (next >= teachers.length) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final teachersAsync = ref.watch(teachersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate(LHome.ourTeachers, locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.translate(LHome.ourTeachersSub, locale),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 28),
          teachersAsync.when(
            data: (teachers) {
              if (teachers.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 280,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final t = teachers[index];
                    final name = t['full_name'] as String? ?? AppLocalizations.translate(LHome.fallbackTeacher, locale);
                    final email = t['email'] as String? ?? '';
                    final subject = t['specialization'] as String? ?? '';
                    final qual = t['qualification'] as String? ?? '';
                    final exp = t['experience_years'] as int? ?? 0;
                    final initial = name.isNotEmpty ? name[0] : '?';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.04),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black.withValues(alpha: 0.15),
                                child: Text(
                                  initial,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              if (subject.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subject,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (qual.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  qual,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (exp > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.translate(LHome.yearsExp, locale).replaceAll('%s', exp.toString()),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  AppLocalizations.translate(LHome.experiencedEducator, locale),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SkeletonList(itemCount: 3),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends ConsumerWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate('home_quick_actions', locale),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              final crossAxisCount =
                  isCompact ? 2 : (constraints.maxWidth < 900 ? 3 : 4);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildQuickActionCard(
                    context,
                    AppLocalizations.translate('home_browse_courses', locale),
                    Icons.search,
                    Colors.black87,
                    () => context.go(AppRoutes.login),
                  ),
                  _buildQuickActionCard(
                    context,
                    AppLocalizations.translate('home_my_learning', locale),
                    Icons.school,
                    Colors.black87,
                    () => context.go(AppRoutes.mobileHome),
                  ),
                  _buildQuickActionCard(
                    context,
                    AppLocalizations.translate('home_certificates', locale),
                    Icons.emoji_events,
                    Colors.orange,
                    () {},
                  ),
                  _buildQuickActionCard(
                    context,
                    AppLocalizations.translate('home_messages', locale),
                    Icons.message,
                    Colors.purple,
                    () {},
                  ),
                  _buildQuickActionCard(
                    context,
                    AppLocalizations.translate('home_settings', locale),
                    Icons.settings,
                    Colors.grey,
                    () => context.go(AppRoutes.settings),
                  ),
                  _buildQuickActionCard(
                    context,
                    AppLocalizations.translate('home_help_support', locale),
                    Icons.help,
                    Colors.red,
                    () {},
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  final Color color;

  const _WindowDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;

  const _BigStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textColor = theme.colorScheme.onPrimary;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}

class MenuScreen extends StatelessWidget {
  final String locale;
  const MenuScreen({super.key, this.locale = 'en'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = locale;

    final items = [
      MenuItemData(Icons.auto_stories_rounded, AppLocalizations.translate(LHome.menuOurStory, l), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const OurStoryScreen()));
      }),
      MenuItemData(Icons.school_rounded, AppLocalizations.translate(LHome.menuOurCourses, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const OurCoursesScreen()));
      }),
      MenuItemData(Icons.business_rounded, AppLocalizations.translate(LHome.menuOurBranches, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const OurBranchesScreen()));
      }),
      MenuItemData(Icons.event_available_rounded, AppLocalizations.translate(LHome.menuNewClasses, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const OurNewClassesScreen()));
      }),
      MenuItemData(Icons.quiz_rounded, AppLocalizations.translate(LHome.menuTestEnglish, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const EnglishTestScreen()));
      }),
      MenuItemData(Icons.edit_document, AppLocalizations.translate(LHome.menuApplyOnline, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ApplyOnlineScreen()));
      }),
      MenuItemData(Icons.phone_callback_rounded, AppLocalizations.translate(LHome.menuRequestCall, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RequestCallScreen()));
      }),
      MenuItemData(Icons.emoji_events_rounded, AppLocalizations.translate(LHome.menuWhyOurCourse, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const WhyOurCourseScreen()));
      }),
      MenuItemData(Icons.star_rounded, AppLocalizations.translate(LHome.menuOurReviews, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const OurReviewsScreen()));
      }),
      MenuItemData(Icons.contact_mail_rounded, AppLocalizations.translate(LHome.menuContactCourse, l), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ContactCourseScreen()));
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(LHome.menu, l)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: theme.colorScheme.primary),
              ),
              title: Text(item.label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: item.onTap,
            ),
          );
        },
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuItemData(this.icon, this.label, this.onTap);
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}

