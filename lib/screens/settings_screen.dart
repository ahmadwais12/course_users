import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/l10n/locale_keys.dart';
import 'package:course_users/nav.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/widgets/adaptive/adaptive_widgets.dart';
import 'package:course_users/widgets/sign_out_dialog.dart';
import 'package:course_users/widgets/insight_ui.dart';
import 'package:course_users/components/skeleton_widgets.dart';
import 'package:course_users/widgets/ad_banner_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final locale = ref.watch(localeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.translate('settings', locale))),
      body: InsightBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              InsightHeroCard(
                eyebrow:
                    AppLocalizations.translate('preferences_account', locale),
                title: user?.userMetadata?['full_name'] ??
                    user?.userMetadata?['name'] ??
                    AppLocalizations.translate('dreamflow_settings', locale),
                subtitle: user?.email ??
                    AppLocalizations.translate('settings_subtitle', locale),
                accent: Colors.black,
                chips: [
                  InsightStatChip(
                    label: AppLocalizations.translate('theme_label', locale),
                    value: isDark
                        ? AppLocalizations.translate('dark', locale)
                        : AppLocalizations.translate('light', locale),
                  ),
                  InsightStatChip(
                    label: AppLocalizations.translate('language_label', locale),
                    value: locale == 'en'
                        ? 'English'
                        : locale == 'fa'
                            ? 'Dari'
                            : 'Pashto',
                  ),
                ],
                actions: [
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.profile),
                    icon: const Icon(Icons.person_outline),
                    label: Text(
                        AppLocalizations.translate('open_profile', locale)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InsightSectionTitle(
                title: AppLocalizations.translate('appearance', locale),
                subtitle:
                    AppLocalizations.translate('appearance_subtitle', locale),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: AppLocalizations.translate('dark_mode', locale),
                trailing: AdaptiveSwitch(
                  value: isDark,
                  onChanged: (value) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: AppLocalizations.translate('language_label', locale),
                subtitle: locale == 'en'
                    ? 'English'
                    : locale == 'fa'
                        ? 'Dari'
                        : 'Pashto',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, ref, locale),
              ),
              const SizedBox(height: 20),
              InsightSectionTitle(
                title:
                    AppLocalizations.translate('notifications_title', locale),
                subtitle: AppLocalizations.translate(
                    'notifications_subtitle', locale),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: AppLocalizations.translate('push_notifications', locale),
                trailing: AdaptiveSwitch(value: true, onChanged: (value) {}),
              ),
              _SettingsTile(
                icon: Icons.payment_outlined,
                title: AppLocalizations.translate('payment_reminders', locale),
                trailing: AdaptiveSwitch(value: true, onChanged: (value) {}),
              ),
              _SettingsTile(
                icon: Icons.event_outlined,
                title: AppLocalizations.translate('exam_reminders', locale),
                trailing: AdaptiveSwitch(value: true, onChanged: (value) {}),
              ),
              const SizedBox(height: 20),
              InsightSectionTitle(
                title: AppLocalizations.translate('account', locale),
                subtitle:
                    AppLocalizations.translate('account_subtitle', locale),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: AppLocalizations.translate('change_password', locale),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.changePassword),
              ),
              _SettingsTile(
                icon: Icons.devices_rounded,
                title: AppLocalizations.translate('logged_in_devices', locale),
                subtitle: AppLocalizations.translate('manage_sessions', locale),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.system_update_rounded,
                title: AppLocalizations.translate('app_update', locale),
                subtitle: AppLocalizations.translate('check_version', locale),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: AppLocalizations.translate('privacy_policy', locale),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: AppLocalizations.translate('about', locale),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context, locale),
              ),
              const SizedBox(height: 20),
              // Ads promotion banner removed - not needed for course_users
              const SizedBox(height: 20),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: AppLocalizations.translate('logout', locale),
                titleColor: Colors.red,
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () async {
                  final shouldSignOut =
                      await showSignOutDialog(context, locale);
                  if (!shouldSignOut) return;
                  await Supabase.instance.client.auth.signOut();
                  ref.read(isDemoModeProvider.notifier).state = false;
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
              const SizedBox(height: 24),
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.translate(
            'select_language', ref.read(localeProvider))),
        content: RadioGroup<String>(
          groupValue: currentLocale,
          onChanged: (v) {
            if (v != null) {
              ref.read(localeProvider.notifier).state = v;
            }
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangTile('English', 'en'),
              _LangTile('Dari', 'fa'),
              _LangTile('Pashto', 'ps'),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.translate('about_dreamflow', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.translate('app_description', locale)),
            const SizedBox(height: 8),
            Text('${AppLocalizations.translate('version', locale)}: 1.0.0'),
            const SizedBox(height: 8),
            Text(AppLocalizations.translate('copyright', locale)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.translate('close', locale)),
          ),
        ],
      ),
    );
  }
}

class LoggedInDevicesScreen extends ConsumerStatefulWidget {
  const LoggedInDevicesScreen({super.key});

  @override
  ConsumerState<LoggedInDevicesScreen> createState() =>
      _LoggedInDevicesScreenState();
}

class _LoggedInDevicesScreenState extends ConsumerState<LoggedInDevicesScreen> {
  List<_DeviceSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final data = await Supabase.instance.client
          .from('device_sessions')
          .select('*')
          .eq('user_id', userId)
          .order('last_active', ascending: false);
      if (mounted) {
        setState(() {
          _sessions = (data as List)
              .map((s) => _DeviceSession(
                    id: s['id'],
                    name: s['device_name'] ?? 'Unknown device',
                    platform: s['device_type'] ?? 'Unknown',
                    location: s['os_version'] ?? 'Unknown',
                    time: s['last_active'] != null
                        ? _formatTime(s['last_active'])
                        : 'Unknown',
                    icon: _deviceIcon(s['device_type']),
                    isCurrent: s['is_current_session'] == true,
                  ))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _deviceIcon(String? type) {
    switch (type) {
      case 'mobile':
        return Icons.phone_android_rounded;
      case 'tablet':
        return Icons.tablet_mac_rounded;
      case 'desktop':
        return Icons.computer_rounded;
      case 'web':
        return Icons.web_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  String _formatTime(dynamic dt) {
    try {
      final diff = DateTime.now().difference(DateTime.parse(dt));
      if (diff.inMinutes < 2) return 'Active now';
      if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
      if (diff.inDays < 1) return '${diff.inHours} hours ago';
      if (diff.inDays < 30) return '${diff.inDays} days ago';
      return '${(diff.inDays / 30).floor()} months ago';
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _sessions.length;
    final currentCount = _sessions.where((s) => s.isCurrent).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Logged-in Devices')),
      body: InsightBackground(
        child: SafeArea(
          top: false,
          child: _loading
              ? const SkeletonList(itemCount: 4)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    InsightHeroCard(
                      eyebrow: 'Session security',
                      title: 'Active devices and recent sign-ins',
                      subtitle:
                          'Review where your account is being used and quickly remove any device you do not recognize.',
                      accent: Colors.black,
                      chips: [
                        InsightStatChip(
                            label: 'Sessions', value: '$activeCount'),
                        InsightStatChip(
                            label: 'Current', value: '$currentCount device'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ..._sessions.map(
                      (device) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(device.icon,
                                    color: Colors.black),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            device.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                        ),
                                        if (device.isCurrent)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black87
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'Current',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${device.platform} • ${device.location}'),
                                    Text(
                                      device.time,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: device.isCurrent
                                    ? null
                                    : () async {
                                        try {
                                          await Supabase.instance.client
                                              .from('device_sessions')
                                              .delete()
                                              .eq('id', device.id);
                                          if (context.mounted) {
                                            setState(() {
                                              _sessions.removeWhere(
                                                  (s) => s.id == device.id);
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Session removed.'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: Text(
                                    device.isCurrent ? 'In use' : 'Sign out'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_sessions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text('No active sessions',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signed out from all other devices.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: const Text(
                        'Sign out all other devices',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppUpdateScreen extends ConsumerWidget {
  const AppUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final currentVersion = packageInfo == null ? '—' : packageInfo.version;
        final buildNumber = packageInfo == null ? '—' : packageInfo.buildNumber;

        return Scaffold(
          appBar: AppBar(
              title:
                  Text(AppLocalizations.translate(LAppUpdate.title, locale))),
          body: InsightBackground(
            child: SafeArea(
              top: false,
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: SkeletonCard(
                        child: Column(
                          children: [
                            const SkeletonLine(width: 180, height: 18),
                            const SizedBox(height: 12),
                            const SkeletonLine(
                                width: double.infinity, height: 14),
                            const SizedBox(height: 8),
                            const SkeletonLine(width: 220, height: 14),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(
                                    child: SkeletonLine(width: 80, height: 32)),
                                const SizedBox(width: 12),
                                const Expanded(
                                    child: SkeletonLine(width: 80, height: 32)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        InsightHeroCard(
                          eyebrow: AppLocalizations.translate(
                              LAppUpdate.releaseManagement, locale),
                          title: AppLocalizations.translate(
                              LAppUpdate.stayOnLatest, locale),
                          subtitle: AppLocalizations.translate(
                              LAppUpdate.trackVersion, locale),
                          accent: Colors.black,
                          chips: [
                            InsightStatChip(
                                label: AppLocalizations.translate(
                                    LAppUpdate.installed, locale),
                                value: currentVersion),
                            InsightStatChip(
                                label: AppLocalizations.translate(
                                    LAppUpdate.build, locale),
                                value: buildNumber),
                          ],
                          actions: [
                            FilledButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.translate(
                                          LAppUpdate.updateCompleted, locale),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(AppLocalizations.translate(
                                  LAppUpdate.checkAgain, locale)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _UpdateStatusCard(
                          title: AppLocalizations.translate(
                              LAppUpdate.currentBuildStatus, locale),
                          value: '$currentVersion+$buildNumber',
                          subtitle: AppLocalizations.translate(
                              LAppUpdate.buildStatusSub, locale),
                          accent: Colors.black,
                          icon: Icons.verified_rounded,
                        ),
                        const SizedBox(height: 12),
                        _UpdateStatusCard(
                          title: AppLocalizations.translate(
                              LAppUpdate.latestRelease, locale),
                          value: '1.0.0',
                          subtitle: AppLocalizations.translate(
                              LAppUpdate.versionMatch, locale),
                          accent: Colors.black,
                          icon: Icons.system_update_alt_rounded,
                        ),
                        const SizedBox(height: 20),
                        InsightSectionTitle(
                          title: AppLocalizations.translate(
                              LAppUpdate.releaseNotes, locale),
                          subtitle: AppLocalizations.translate(
                              LAppUpdate.releaseNotesSub, locale),
                        ),
                        const SizedBox(height: 12),
                        _ReleaseNoteTile(
                          title: AppLocalizations.translate(
                              LAppUpdate.note1Title, locale),
                          details: AppLocalizations.translate(
                              LAppUpdate.note1Desc, locale),
                        ),
                        _ReleaseNoteTile(
                          title: AppLocalizations.translate(
                              LAppUpdate.note2Title, locale),
                          details: AppLocalizations.translate(
                              LAppUpdate.note2Desc, locale),
                        ),
                        _ReleaseNoteTile(
                          title: AppLocalizations.translate(
                              LAppUpdate.note3Title, locale),
                          details: AppLocalizations.translate(
                              LAppUpdate.note3Desc, locale),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final String value;

  const _LangTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(value: value),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _DeviceSession {
  final dynamic id;
  final String name;
  final String platform;
  final String location;
  final String time;
  final IconData icon;
  final bool isCurrent;

  const _DeviceSession({
    required this.id,
    required this.name,
    required this.platform,
    required this.location,
    required this.time,
    required this.icon,
    this.isCurrent = false,
  });
}

class _UpdateStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;

  const _UpdateStatusCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleaseNoteTile extends StatelessWidget {
  final String title;
  final String details;

  const _ReleaseNoteTile({
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(details),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
