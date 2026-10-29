import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/nav.dart';
import 'package:course_users/components/components.dart';
import 'package:course_users/l10n/locale_keys.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  // No tracking table in the schema; use a static list.
  static const List<Map<String, dynamic>> _demoAccountsList = [
    {
      'role': 'student',
      'display_name': 'Student',
      'email': 'student@emis.com',
      'password': 'demo123',
      'icon_name': 'school',
      'color_name': 'blue',
      'avatar_url': null,
      'student_id': null,
    },
    {
      'role': 'parent',
      'display_name': 'Parent',
      'email': 'parent@emis.com',
      'password': 'demo123',
      'icon_name': 'family_restroom',
      'color_name': 'teal',
      'avatar_url': null,
      'student_id': null,
    },
    {
      'role': 'teacher',
      'display_name': 'Teacher',
      'email': 'teacher@emis.com',
      'password': 'demo123',
      'icon_name': 'teacher',
      'color_name': 'green',
      'avatar_url': null,
      'student_id': null,
    },
    {
      'role': 'admin',
      'display_name': 'Admin',
      'email': 'admin@emis.com',
      'password': 'demo123',
      'icon_name': 'admin',
      'color_name': 'purple',
      'avatar_url': null,
      'student_id': null,
    },
  ];

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'school':
        return Icons.school;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'teacher':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  Color _colorFromName(String? name) {
    switch (name) {
      case 'blue':
        return Colors.black87;
      case 'teal':
        return Colors.black87;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.black87;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String? _validateEmail(String? value) {
    final l = ref.read(localeProvider);
    if (value == null || value.isEmpty) {
      return AppLocalizations.translate(LLogin.emailRequired, l);
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.translate(LLogin.invalidEmail, l);
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l = ref.read(localeProvider);
    if (value == null || value.isEmpty) {
      return AppLocalizations.translate(LLogin.passwordRequired, l);
    }
    if (value.length < 6) {
      return AppLocalizations.translate(LLogin.min6Chars, l);
    }
    return null;
  }

  Future<void> _signIn() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtl.text.trim(),
        password: _passwordCtl.text,
      );
      if (mounted) context.go(AppRoutes.dashboard);
    } on AuthException {
      final email = _emailCtl.text.trim().toLowerCase();
      final isDemoEmail = email.endsWith('@emis.com');

      if (!isDemoEmail) {
        setState(() => _errorMessage = AppLocalizations.translate(
            LLogin.invalidCredentials, ref.read(localeProvider)));
        setState(() => _loading = false);
        return;
      }

      final role = email.split('@')[0];
      final demoPassword = _passwordCtl.text;
      Map<String, dynamic>? userData = _mockUsers[role];

      if (userData == null || demoPassword != 'demo123') {
        setState(() => _errorMessage = AppLocalizations.translate(
            LLogin.badDemoCredentials, ref.read(localeProvider)));
        setState(() => _loading = false);
        return;
      }

      await Supabase.instance.client.auth.signUp(
        email: _emailCtl.text.trim(),
        password: demoPassword,
        data: userData,
      );
      if (mounted) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtl.text.trim(),
          password: demoPassword,
        );
        if (mounted) context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, Map<String, dynamic>> get _mockUsers => {
        for (final acc in _demoAccountsList)
          acc['role'] as String: {
            'name': acc['display_name'] ?? acc['role'],
            'role': acc['role'],
            'avatar_url': acc['avatar_url'],
            'student_id': acc['student_id'],
          },
      };

  List<Widget> _buildDemoGroups() {
    final locale = ref.read(localeProvider);
    final List<(String, String, String, IconData, Color)> accounts =
        _demoAccountsList
            .map((acc) => (
                  (acc['display_name'] as String?) ??
                      AppLocalizations.translate(LLogin.student, locale),
                  acc['email'] as String,
                  acc['password'] as String,
                  _iconFromName(acc['icon_name'] as String?),
                  _colorFromName(acc['color_name'] as String?),
                ))
            .toList();
    return [
      _buildDemoGroup(
          AppLocalizations.translate(LLogin.studentPanels, locale), accounts)
    ];
  }

  Widget _buildDemoGroup(
      String title, List<(String, String, String, IconData, Color)> accounts) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
        ...accounts.map((acc) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: acc.$5.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(acc.$4, color: acc.$5, size: 20),
              ),
              title: Text(acc.$1,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(acc.$2, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              onTap: () {
                _emailCtl.text = acc.$2;
                _passwordCtl.text = acc.$3;
                Navigator.pop(context);
                _signIn();
              },
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/logo/dreamflow-icon-filled-256.png'
                          : 'assets/logo/dreamflow-icon-black.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppFadingText(
                        texts: [
                          AppLocalizations.translate(
                              LLogin.welcomeBack1, locale),
                          AppLocalizations.translate(
                              LLogin.welcomeBack2, locale),
                          AppLocalizations.translate(
                              LLogin.welcomeBack3, locale),
                        ],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        duration: const Duration(seconds: 2),
                        height: 24,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text(AppLocalizations.translate(
                            LLogin.backToHome, locale)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.translate('email', locale),
                        hintText: AppLocalizations.translate(
                            LLogin.emailHint, locale),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordCtl,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.translate('password', locale),
                        hintText: AppLocalizations.translate(
                            LLogin.passwordHint, locale),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.forgotPassword),
                        child: Text(
                          AppLocalizations.translate('forgot_password', locale),
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton.filled(
                      label: AppLocalizations.translate('login', locale),
                      onPressed: _signIn,
                      loading: _loading,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: theme.colorScheme.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.translate(LLogin.noAccount, locale),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signup),
                          child: Text(
                            AppLocalizations.translate('sign_up', locale),
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.translate(LLogin.demoAccounts, locale),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_demoAccountsList.isEmpty)
                      _buildDemoGroup(
                          AppLocalizations.translate(
                              LLogin.studentPanels, locale),
                          [
                            (
                              AppLocalizations.translate(
                                  LLogin.student, locale),
                              'student@emis.com',
                              'demo123',
                              Icons.school,
                              Colors.black87
                            ),
                            (
                              AppLocalizations.translate(LLogin.parent, locale),
                              'parent@emis.com',
                              'demo123',
                              Icons.family_restroom,
                              Colors.black87
                            ),
                          ])
                    else
                      ..._buildDemoGroups(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
