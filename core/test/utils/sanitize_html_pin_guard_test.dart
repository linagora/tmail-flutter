import 'package:core/presentation/utils/html_transformer/sanitize_html.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the pinned `sanitize_html` version: the nested CSS fix must be
/// present in what the app actually runs. The library tests cover the rules
/// in depth; here every nesting is crossed with every dangerous declaration,
/// so a re-pin or upgrade that loses the fix fails in the app too.
void main() {
  const nestings = {
    'plain': '{rule}',
    '@media': '@media (max-width: 600px) { {rule} }',
    'dark mode @media': '@media (prefers-color-scheme: dark) { {rule} }',
    '@supports': '@supports (display: grid) { {rule} }',
    'nested @media': '@media all { @media (min-width: 1px) { {rule} } }',
    'next to an empty @media': '@media print { } {rule}',
    'after a comment': '/* layout */ @media screen { {rule} }',
  };

  const dangerous = [
    'position: fixed',
    'position: absolute',
    'z-index: 9999',
    'behavior: url(x.htc)',
    '-moz-binding: url(x.xml#y)',
  ];

  String keptCss(String css) => RegExp(r'<style[^>]*>(.*?)</style>', dotAll: true)
      .allMatches(SanitizeHtml().process(inputHtml: '<style>$css</style><p class="x">x</p>'))
      .map((match) => match.group(1)!)
      .join(' ')
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();

  nestings.forEach((nesting, template) {
    for (final declaration in dangerous) {
      test('$nesting drops "$declaration" and keeps "color: red"', () {
        final css = template.replaceFirst('{rule}', '.x { color: red; $declaration }');
        final kept = keptCss(css);
        final property = declaration.split(':').first;

        expect(kept, isNot(contains('$property:')), reason: 'input: $css\nkept: $kept');
        if (nesting != '@supports' && nesting != 'nested @media') {
          expect(kept, contains('color:red'), reason: 'input: $css\nkept: $kept');
        }
      });
    }
  });
}
