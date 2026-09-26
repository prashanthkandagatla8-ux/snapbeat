// Guards against tofu boxes in the UI.
//
// SnapBeat bundles no font files — there is no `flutter: fonts:` block in
// pubspec.yaml — so all text renders in the platform default: SF Pro on iOS,
// Roboto on Android. Neither carries emoji or dingbat glyphs, so any emoji baked
// into a string literal renders as an empty box. Several shipped screens did
// exactly that.
//
// This test fails on any character outside the allowed set appearing inside a
// Dart string literal under lib/. If you need a new symbol, confirm both SF Pro
// and Roboto cover it before adding it to `allowed`.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Characters confirmed present in both SF Pro and Roboto.
const Set<int> allowed = {
  0x20b9, // rupee sign, used by the fallback price table
  0x2022, // bullet, inline separator
  0x00b7, // middle dot
  0x00d7, // multiplication sign
  0x2013, // en dash
  0x2014, // em dash
  0x2018, 0x2019, 0x201c, 0x201d, // curly quotes
  0x00a9, 0x00ae, // copyright, registered
  0x00b0, // degree
  0x00a0, // non-breaking space
};

/// Matches Dart string literals: triple-quoted, then single-line single/double.
final RegExp _stringLiteral = RegExp(
  r"""('''(?:.|\n)*?'''|"""
  r'"""(?:.|\n)*?"""|'
  r"'(?:\\.|[^'\\\n])*'|"
  r'"(?:\\.|[^"\\\n])*")',
);

void main() {
  test('no unrenderable glyphs in lib/ string literals', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue,
        reason: 'run this from the package root');

    final failures = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final lines = entity.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        // Comments are never rendered.
        if (trimmed.startsWith('//')) continue;

        for (final match in _stringLiteral.allMatches(line)) {
          for (final rune in match.group(0)!.runes) {
            if (rune < 128 || allowed.contains(rune)) continue;
            failures.add(
              '${entity.path}:${i + 1}  U+${rune.toRadixString(16).toUpperCase()}'
              '  ${trimmed.length > 100 ? '${trimmed.substring(0, 100)}...' : trimmed}',
            );
          }
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'These characters have no glyph in SF Pro or Roboto and will '
          'render as tofu boxes. Use a vector IconData instead:\n'
          '${failures.join('\n')}',
    );
  });
}
