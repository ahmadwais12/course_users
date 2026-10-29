import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:course_users/providers/tenant_provider.dart';
import 'package:course_users/providers/navigation_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';
import 'package:course_users/nav.dart';
import 'package:course_users/core/responsive/extensions.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';

// Module Screen Imports
import 'package:course_users/screens/attendance_screen.dart';

import 'package:course_users/screens/notifications_screen.dart';
import 'package:course_users/screens/settings_screen.dart';
import 'package:course_users/screens/home_page.dart';
import 'package:course_users/screens/chat_screen.dart';
import 'package:course_users/screens/schema_pages.dart';

// Student module screens
import 'package:course_users/screens/student/student_screens.dart';

// Parent module screens
import 'package:course_users/screens/parent/parent_screens.dart';

// Staff Module Imports - Commented out as these belong to course_team app
// import 'package:course_users/screens/staff_academic_support_screen.dart';
// import 'package:course_users/screens/staff_accountant_screen.dart';
// import 'package:course_users/screens/staff_librarian_screen.dart';
// import 'package:course_users/screens/staff_frontdesk_screen.dart';
// import 'package:course_users/screens/staff_hr_screen.dart';
// import 'package:course_users/screens/staff_inventory_manager_screen.dart';
// import 'package:course_users/screens/staff_it_support_screen.dart';
// import 'package:course_users/screens/staff_maintenance_screen.dart';
// import 'package:course_users/screens/staff_event_coordinator_screen.dart';
// import 'package:course_users/screens/staff_complaint_manager_screen.dart';

class BasePanelLayout extends ConsumerWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final List<BottomNavigationBarItem>? customBottomNavItems;
  final Function(int)? onBottomNavTap;
  final bool isLoading;
  final bool showBackButton;

  const BasePanelLayout({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.floatingActionButton,
    this.customBottomNavItems,
    this.onBottomNavTap,
    this.isLoading = false,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTenant = ref.watch(currentTenantProvider);
    final navIndex = ref.watch(navigationIndexProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final role =
        user?.userMetadata?['role']?.toString().toLowerCase() ?? 'student';
    final locale = ref.watch(localeProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      extendBody: !isDesktop,
      drawer: isDesktop
          ? null
          : _buildDrawer(context, ref, role, currentTenant, locale),
      floatingActionButton: PlatformAdaptive.showFab && floatingActionButton != null
          ? SizedBox(
              width: 56,
              height: 56,
              child: floatingActionButton!
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut)
                  .slideY(begin: 0.5, end: 0),
            )
          : null,
      bottomNavigationBar: isDesktop
          ? null
          : _buildBottomNav(context, ref, role, locale)
              ?.animate()
              .slideY(begin: 1, end: 0, duration: 300.ms),
      body: isDesktop
          ? _buildDesktopBody(context, ref, theme, role, navIndex, locale)
          : _buildMobileBody(
              context, ref, theme, role, navIndex, locale, currentTenant),
    );
  }

  Widget _buildDesktopBody(BuildContext context, WidgetRef ref, ThemeData theme,
      String role, int navIndex, String locale) {
    final navItems = [
      (
        Icons.home_outlined,
        Icons.home_rounded,
        AppLocalizations.translate('home', locale)
      ),
      (
        Icons.menu_book_outlined,
        Icons.menu_book_rounded,
        AppLocalizations.translate(LBasePanel.courses, locale)
      ),
      (
        Icons.assignment_outlined,
        Icons.assignment_rounded,
        AppLocalizations.translate(LBasePanel.assignments, locale)
      ),
      (
        Icons.schedule_outlined,
        Icons.schedule_rounded,
        AppLocalizations.translate(LBasePanel.mySchedule, locale)
      ),
      (
        Icons.grade_outlined,
        Icons.grade_rounded,
        AppLocalizations.translate(LBasePanel.grades, locale)
      ),
    ];

    return Row(
      children: [
        Container(
          width: 260,
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              DrawerHeader(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.school_rounded,
                          color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      role.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: navItems.length,
                  itemBuilder: (context, index) {
                    final (icon, selectedIcon, label) = navItems[index];
                    final selected = navIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          selected ? selectedIcon : icon,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        selected: selected,
                        selectedTileColor:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onTap: () {
                          ref.read(navigationIndexProvider.notifier).state =
                              index;
                          if (onBottomNavTap != null) onBottomNavTap!(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.outlined(
                      icon: const Icon(Icons.notifications_outlined, size: 20),
                      onPressed: () => context.go('/notifications'),
                      tooltip: 'Notifications',
                    ),
                    IconButton.outlined(
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      onPressed: () => context.go('/settings'),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: _buildMobileBody(
                  context, ref, theme, role, navIndex, locale, null),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context, WidgetRef ref, ThemeData theme,
      String role, int navIndex, String locale, dynamic currentTenant) {
    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.02),
              theme.colorScheme.secondary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: navIndex != 0
            ? AnnotatedRegion<SystemUiOverlayStyle>(
                value: theme.brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: _buildNavContent(context, role, navIndex, locale),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 80,
                    collapsedHeight: 80,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    systemOverlayStyle: theme.brightness == Brightness.dark
                        ? SystemUiOverlayStyle.dark
                        : SystemUiOverlayStyle.light,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    leadingWidth: showBackButton ? 80 : 56,
                    leading: showBackButton
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    locale == 'ps' || locale == 'fa'
                                        ? Icons.arrow_forward_rounded
                                        : Icons.arrow_back_rounded,
                                  ),
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      context.go('/dashboard');
                                    }
                                  },
                                  tooltip:
                                      AppLocalizations.translate('back', locale),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.1),
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.menu_rounded),
                                  onPressed: () =>
                                      Scaffold.of(context).openDrawer(),
                                  tooltip:
                                      AppLocalizations.translate('menu', locale),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.1),
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu_rounded),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              tooltip:
                                  AppLocalizations.translate('menu', locale),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.1),
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      titlePadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary
                                  .withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: -30,
                              top: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.04),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.4, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                    actions: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.redAccent.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_active_rounded,
                              size: 22,
                            ),
                            onPressed: () => context.go('/notifications'),
                            tooltip: AppLocalizations.translate(
                                'notifications', locale),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      if (actions != null) ...actions!,
                    ],
                  ),
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(child: AdaptiveProgress()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildQuickActions(context, role, locale),
                          ...children,
                        ]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavContent(
      BuildContext context, String role, int index, String locale) {
    switch (role) {
      case 'student':
        switch (index) {
          case 1:
            return const CoursesScreen();
          case 2:
            return const AssignmentsScreen();
          case 3:
            return const ScheduleScreenRealtime();
          case 4:
            return const GradesScreenRealtime();
          default:
            return const SizedBox.shrink();
        }
      case 'parent':
        switch (index) {
          case 1:
            return const ChildrenProfileScreen();
          case 2:
            return const MessagesHubScreen();
          case 3:
            return const NotificationsScreen();
          default:
            return const SizedBox.shrink();
        }
      // Staff cases commented out - these belong to course_team app
      /*
      case 'academic_support':
        if (index == 1) return const StaffAcademicSupportScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'accountant':
        if (index == 1) return StaffAccountantScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'librarian':
        if (index == 1) return StaffLibrarianScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'receptionist':
        if (index == 1) return StaffFrontDeskScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'hr_manager':
        if (index == 1) return StaffHRScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'inventory_manager':
        if (index == 1) return StaffInventoryManagerScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'it_support':
        if (index == 1) return StaffITSupportScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'maintenance':
        if (index == 1) return StaffMaintenanceScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'event_manager':
        if (index == 1) return StaffEventCoordinatorScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      case 'complaint_manager':
        if (index == 1) return StaffComplaintManagerScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      */
      case 'staff':
        if (index == 1) return AttendanceScreen();
        if (index == 2) return const ChatScreen();
        if (index == 3) return NotificationsScreen();
        break;
      default:
        if (index == 1) return const ChatScreen();
        if (index == 2) return NotificationsScreen();
        if (index == 3) return SettingsScreen();
    }

    return _buildComingSoon(locale);
  }

  Widget _buildComingSoon(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.translate('bp_coming_soon', locale),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.translate('bp_under_development', locale),
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Helper method to build placeholder screens
  Widget _buildQuickActions(BuildContext context, String role, String locale) {
    return const SizedBox.shrink();
  }

  Widget? _buildBottomNav(
      BuildContext context, WidgetRef ref, String role, String locale) {
    final navIndex = ref.watch(navigationIndexProvider);

    List<NavigationDestination> destinations = [
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'Courses',
      ),
      NavigationDestination(
        icon: Icon(Icons.contact_mail_outlined),
        selectedIcon: Icon(Icons.contact_mail_rounded),
        label: 'Contact',
      ),
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications_rounded),
        label: 'Notifications',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_rounded),
        label: 'Menu',
      ),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: NavigationBar(
        selectedIndex: navIndex,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 10, fontWeight: FontWeight.w600);
          }
          return const TextStyle(fontSize: 10);
        }),
        onDestinationSelected: (i) {
          ref.read(navigationIndexProvider.notifier).state = i;
          if (i == 2) return;
          switch (i) {
            case 0:
              context.go(AppRoutes.courses);
              break;
            case 1:
              context.go(AppRoutes.helpSupport);
              break;
            case 3:
              context.go(AppRoutes.notifications);
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              );
              break;
          }
        },
        height: 72,
        destinations: destinations,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, String role,
      dynamic currentTenant, String locale) {
    return const SizedBox.shrink();
  }
}
