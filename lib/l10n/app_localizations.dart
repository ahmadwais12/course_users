import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_localizations_en.dart';
import 'app_localizations_prs.dart';
import 'app_localizations_ps.dart';

/// Current locale code provider.
///
/// Canonical codes: `en` (English), `prs` (Dari), `ps` (Pashto).
/// The legacy alias `fa` is accepted everywhere and normalized to `prs`.
final localeProvider = StateProvider<String>((ref) => 'en');

/// Canonical locale code — maps the `fa` alias to `prs`.
String canonicalLocale(String locale) =>
    locale == 'fa' ? 'prs' : locale;

/// RTL direction provider — derived from locale.
final isRtlProvider = Provider<bool>((ref) {
  final locale = canonicalLocale(ref.watch(localeProvider));
  return locale == 'ps' || locale == 'prs';
});

/// TextDirection from locale.
final textDirectionProvider = Provider<TextDirection>((ref) {
  final locale = canonicalLocale(ref.watch(localeProvider));
  return (locale == 'ps' || locale == 'prs')
      ? TextDirection.rtl
      : TextDirection.ltr;
});

/// AppLocalizations — centralized translation lookups.
class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': AppLocalizationsEn.values,
    'prs': AppLocalizationsPrs.values,
    'ps': AppLocalizationsPs.values,
  };

  static String translate(String key, String locale) {
    final lang = canonicalLocale(locale);
    return _localizedValues[lang]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// Convenience: translate [key] using the current app locale resolved from
  /// [context]. Works inside any widget's build method (Consumer or not) —
  /// no `ref` or widget-type conversion required.
  static String tr(BuildContext context, String key) {
    final container = ProviderScope.containerOf(context, listen: true);
    return translate(key, container.read(localeProvider));
  }

  /// Like [tr] but uses a plain read (no provider subscription). Safe to call
  /// outside build (snackbars, callbacks, async handlers).
  static String trRead(BuildContext context, String key) {
    final container = ProviderScope.containerOf(context);
    return translate(key, container.read(localeProvider));
  }
}

/// Short alias so screens can write `tr(context, 'key')`.
String tr(BuildContext context, String key) =>
    AppLocalizations.tr(context, key);

/// Non-watching alias for callbacks/snackbars: `trRead(context, 'key')`.
String trRead(BuildContext context, String key) =>
    AppLocalizations.trRead(context, key);
