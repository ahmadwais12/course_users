import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:course_users/theme.dart';
import 'package:course_users/l10n/app_localizations.dart';
import 'package:course_users/nav.dart';
import 'package:course_users/l10n/locale_keys.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _errorMessage;

  String get _l => ref.read(localeProvider);

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.translate(LSignup.nameRequired, _l);
    }
    if (value.length < 3) {
      return AppLocalizations.translate(LSignup.nameMinChars, _l);
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.translate(LSignup.emailRequired, _l);
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.translate(LSignup.invalidEmail, _l);
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.translate(LSignup.passwordRequired, _l);
    }
    if (value.length < 8) {
      return AppLocalizations.translate(LSignup.passwordMinChars, _l);
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppLocalizations.translate(LSignup.passwordUppercase, _l);
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppLocalizations.translate(LSignup.passwordNumber, _l);
    }
    return null;
  }

  Future<void> _signUp() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailCtl.text.trim(),
        password: _passwordCtl.text,
        data: {'full_name': _nameCtl.text},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.translate(LSignup.accountCreated, _l))),
        );
        context.go('/login');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = AppLocalizations.translate(LSignup.unexpectedError, _l));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                                theme.colorScheme.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppGradients.skyCyanHorizontal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              isDark
                                  ? 'assets/logo/dreamflow-icon-filled-256.png'
                                  : 'assets/logo/dreamflow-icon-black.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.translate(LSignup.createAccount, locale),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.home);
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: Icon(Icons.arrow_back_rounded, size: 20, color: theme.colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtl,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.translate('full_name', locale),
                            hintText: AppLocalizations.translate(LSignup.nameHint, locale),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailCtl,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.translate('email', locale),
                            hintText: AppLocalizations.translate(LSignup.emailHint, locale),
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                            labelText: AppLocalizations.translate('password', locale),
                            hintText: AppLocalizations.translate(LSignup.passwordHint, locale),
                            prefixIcon: const Icon(Icons.lock_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.1), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _loading ? null : _signUp,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _loading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                                : Text(AppLocalizations.translate('signup', locale), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.translate('already_have_account', locale).isEmpty
                                  ? "Already have an account? "
                                  : AppLocalizations.translate('already_have_account', locale),
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: Text(
                                AppLocalizations.translate('login', locale).isEmpty ? 'Login' : AppLocalizations.translate('login', locale),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
