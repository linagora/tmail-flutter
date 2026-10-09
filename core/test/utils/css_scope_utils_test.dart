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

    test('should end an unterminated string at a lone carriage return or form feed', () {
      expect(
        CssScopeUtils.scope('.a { content: "{\r} } .b { content: "{\f} } .c {}', root),
        scoped('.a { content: "{\n}   .b { content: "{\n}   .c {}'),
      );
    });

    test('should honor escaped newlines inside strings', () {
      expect(
        CssScopeUtils.scope('.a { content: "\\\r\n{" } } .b {}', root),
        scoped('.a { content: "\\\n{" }   .b {}'),
      );
    });

    test('should keep a string open across the newline swallowed by a hex escape', () {
      expect(
        CssScopeUtils.scope('"\\a\n(}\n} .b {}', root),
        scoped('"\\a\n(}\n  .b {}'),
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

    test('should not end an unquoted url token at an escaped parenthesis', () {
      const css = r'.a { b: url(x\) } ) } .c {}';

      expect(CssScopeUtils.scope(css, root), scoped(css));
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

    test('should read <!-- as one token so a following url( is a url token', () {
      expect(
        CssScopeUtils.scope('<!--url(x{) } .b {}', root),
        scoped('<!--url(x{)   .b {}'),
      );
      expect(
        CssScopeUtils.scope(r'<!--\75rl(x{) } .b {}', root),
        scoped(r'<!--\75rl(x{)   .b {}'),
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

    test('should end a number before a full stop not followed by a digit', () {
      expect(
        CssScopeUtils.scope('.a { b: 1.url( ( ) } } .c {}', root),
        scoped('.a { b: 1.url( ( ) }   .c {}'),
      );
    });

    test('should treat a hyphen-prefixed url( as a function, not a url token', () {
      const css = '.a { b: -url( ( ) } } .c {}';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should read signed, decimal, exponent and percentage numbers as one token', () {
      const css = '.a { b: +.5e-3url( ( ) } } .c { d: 50% -1E+2px }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
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

    test('should rewrite html and body type selectors to :scope', () {
      expect(
        CssScopeUtils.scope('body { background: blue } html, BODY {} body .a, body > .b {}', root),
        scoped(':scope { background: blue } :scope, :scope {} :scope .a, :scope > .b {}'),
      );
    });

    test('should rewrite html followed by body to a single :scope', () {
      expect(
        CssScopeUtils.scope('html body .a, html > body .b, html .c {}', root),
        scoped(':scope .a, :scope .b, :scope .c {}'),
      );
    });

    test('should not join html and body separated by a non-whitespace control character', () {
      expect(
        CssScopeUtils.scope('html\u000Bbody {}', root),
        scoped(':scope\u000B:scope {}'),
      );
    });

    test('should rewrite html and body inside grouping at-rules and pseudo-classes', () {
      expect(
        CssScopeUtils.scope('@media screen { body .a {} } :not(body) {} b\\6f dy {}', root),
        scoped('@media screen { :scope .a {} } :not(:scope) {} :scope {}'),
      );
    });

    test('should not rewrite body when it is not a type selector', () {
      const css = '.body, #body, a:body, [data-x=body], ns|body, body|a, body() {} '
          '.a { font-family: body } @font-face { font-family: body } @scope (body) {} '
          '@counter-style body {} .a { .b body {} }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });

    test('should restart selector detection after a statement at-rule', () {
      expect(
        CssScopeUtils.scope('@charset "utf-8"; body {}', root),
        scoped('@charset "utf-8"; :scope {}'),
      );
    });

    test('should replace NULL characters', () {
      expect(
        CssScopeUtils.scope('.a\u0000 {}', root),
        scoped('.a� {}'),
      );
    });

    // `<style>` text is serialized raw, so a `}` turned into whitespace can
    // complete `</style` into an end tag and let the rest parse as HTML.
    test('should never produce a style end tag from a neutralized brace', () {
      final output = CssScopeUtils.scope('</style}><img src=x onerror=alert(1)>', root);

      expect(output, isNot(matches(RegExp(r'</style[\s/>]', caseSensitive: false))));
    });

    test('should never produce a style end tag whatever the letter case', () {
      final output = CssScopeUtils.scope('</STYLE} ><img src=x>', root);

      expect(output, isNot(matches(RegExp(r'</style[\s/>]', caseSensitive: false))));
    });

    test('should never produce a style end tag from the newline closing the @scope block', () {
      final output = CssScopeUtils.scope('.a {} </style', root);

      expect(output, isNot(matches(RegExp(r'</style[\s/>]', caseSensitive: false))));
    });

    test('should escape a style end tag without changing what the CSS reads', () {
      expect(
        CssScopeUtils.scope('.a { content: "</style>" } </style} .b {}', root),
        scoped(r'.a { content: "<\/style>" } <\/style  .b {}'),
      );
    });

    // `body` weighs (0,0,1) while `:scope` weighs (0,1,0): the rewrite must not
    // let a mail rule beat a rule it used to lose to, or content gets hidden.
    test('should rewrite body without raising its specificity', () {
      expect(
        CssScopeUtils.scope('.show .promo { display: block } body .promo { display: none }', root),
        scoped('.show .promo { display: block } :where(:scope) .promo { display: none }'),
      );
    });

    test('should rewrite html followed by body without raising its specificity', () {
      expect(
        CssScopeUtils.scope('html > body .a {}', root),
        scoped(':where(:scope) .a {}'),
      );
    });

    // `u+div` is a `<div>` right after a `<u>`: dropping the whole stylesheet
    // for it also drops rules that hide content, such as preheaders.
    test('should keep the stylesheet when u+element is an adjacent sibling selector', () {
      const css = 'u+div { color: red } .hidden-preheader { display: none }';

      expect(CssScopeUtils.scope(css, root), scoped(css));
    });
  });
}
