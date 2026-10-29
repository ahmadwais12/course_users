// Command-line locale checker: console output is the intended interface.
// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final def = <String, String>{};
  String cur = '';
  for (final line in File('lib/l10n/locale_keys.dart').readAsLinesSync()) {
    final cls = RegExp(r'class (\w+)').firstMatch(line);
    if (cls != null) {
      cur = cls.group(1)!;
      continue;
    }
    final c = RegExp(r"static const (\w+) = '([^']+)'").firstMatch(line);
    if (c != null) {
      def['$cur.${c.group(1)}'] = c.group(2)!;
    }
  }

  final inAll = <String>{};
  for (final f in ['en', 'prs', 'ps']) {
    final present = <String>{};
    for (final line in File('lib/l10n/app_localizations_$f.dart').readAsLinesSync()) {
      final p = RegExp(r"'([^']+)':").firstMatch(line);
      if (p != null) {
        present.add(p.group(1)!);
        continue;
      }
      final r = RegExp(r"\b(L[\w]*)\.(\w+):").firstMatch(line);
      if (r != null) {
        final v = def['${r.group(1)}.${r.group(2)}'];
        if (v != null) present.add(v);
      }
    }
    if (f == 'en') {
      inAll.addAll(present);
    } else {
      inAll.removeWhere((k) => !present.contains(k));
    }
  }
  print('Keys present in all three locales: ${inAll.length}');

  final rawRefs = <String>{};
  for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (file.path.contains('l10n')) continue;
    for (final line in file.readAsLinesSync()) {
      for (final m in RegExp(r"translate\(\s*'([^']+)'\s*[,)]").allMatches(line)) {
        rawRefs.add(m.group(1)!);
      }
    }
  }
  print('Raw string translate refs: ${rawRefs.length}');
  final missing = rawRefs.where((k) => !inAll.contains(k)).toList()..sort();
  print('Missing from ALL locales but used in app: ${missing.length}');
  for (final k in missing) {
    print('  $k');
  }
}