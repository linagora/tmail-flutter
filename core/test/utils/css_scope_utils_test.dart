import 'package:core/utils/html/css_scope_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const root = '.email-body';

  String scoped(String body) => '@scope ($root) {\n$body\n}';

  group('CssScopeUtils.scope', () {
    test('should wrap well formed CSS into an @scope block', () {
      const css = '* { font-family: "Comic Sans MS" !important } '
          '@media (max-width: 600px) { .a { color: red } }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should neutralize a stray closing brace escaping the @scope block', () {
      expect(
        CssScopeUtils.scope('.a { color: red } } .sender-email { display: none }', root),
        scoped('.a { color: red }   .sender-email { display: none }'),
      );
    });

    test('should neutralize leading stray closing braces', () {
      expect(
        CssScopeUtils.scope('}}} * { color: red }', root),
        scoped('    * { color: red }'),
      );
    });

    test('should keep closing braces swallowed by a parenthesis block', () {
      const css = '.a { color: foo(}) }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should ignore braces inside comments and strings', () {
      const css = '/* } */ .a::before { content: "}" } .b::after { content: \'\\\'}\' }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should end an unterminated string at the next newline', () {
      expect(
        CssScopeUtils.scope('.a { content: "{\n} } .b { color: red }', root),
        scoped('.a { content: "{\n}   .b { color: red }'),
      );
    });

    test('should honor escaped newlines inside strings', () {
      expect(
        CssScopeUtils.scope('.a { content: "\\\r\n{" } } .b {}', root),
        scoped('.a { content: "\\\n{" }   .b {}'),
      );
    });

    test('should not treat an escaped brace as a block delimiter', () {
      expect(
        CssScopeUtils.scope('.a\\{ { color: red } \\} } .b {}', root),
        scoped('.a\\{ { color: red } \\}   .b {}'),
      );
    });

    test('should skip braces inside an unquoted url token', () {
      expect(
        CssScopeUtils.scope('.a { background: url(x{) } } .b {}', root),
        scoped('.a { background: url(x{) }   .b {}'),
      );
    });

    test('should recognize url tokens spelled with escapes', () {
      expect(
        CssScopeUtils.scope('.a { background: u\\72 l(x{) } } .b {}', root),
        scoped('.a { background: u\\72 l(x{) }   .b {}'),
      );
      expect(
        CssScopeUtils.scope('.a { background: \\75rl(x{) } } .b {}', root),
        scoped('.a { background: \\75rl(x{) }   .b {}'),
      );
    });

    test('should treat quoted url as a function', () {
      const css = '.a { background: url( "x{" ) } .b {}';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should not treat a dimension unit named url as a url token', () {
      expect(
        CssScopeUtils.scope('.a { width: 10url(x{) } }) } } .b {}', root),
        scoped('.a { width: 10url(x{) } }) }   .b {}'),
      );
    });

    test('should not treat a hash or an at-keyword named url as a url token', () {
      const css = '.a { b: #url(x{) } } .c { d: @url(x{) } }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should not treat braces in an unterminated comment as delimiters', () {
      const css = '.a { color: red } /* }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should accept unicode ranges', () {
      const css = '.a { unicode-range: U+0025-00FF, u+4?? }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should reject unicode ranges tokenized differently across browsers', () {
      expect(CssScopeUtils.scope('.a { b: u+aurl(x{) } } .c {}', root), isEmpty);
    });

    test('should replace NULL characters', () {
      expect(
        CssScopeUtils.scope('.a\u0000 {}', root),
        scoped('.a� {}'),
      );
    });
  });
}
