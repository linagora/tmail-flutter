/// Test corpus for HTML email content.
abstract final class HtmlEmailCorpus {
  // ─── Simple ────────────────────────────────────────────────────────────────
  static const String simpleParagraph = '<p>Hello World</p>';
  static const String withBold = '<p>Hello <strong>World</strong>!</p>';
  static const String withSafeLink =
      '<p>Visit <a href="https://example.com">our site</a>.</p>';
  static const String withUnicode = '<p>مرحبا 🎉 résumé 日本語 한국어</p>';

  // ─── Backslash namespace / path patterns in text nodes ────────────────────
  static const String backslashInCode =
      r'<p>Error: <code>\App\DB\Exception\AuthFailed</code> — access denied.</p>'
      '<p>Check the docs for details.</p>';
  static const String backslashMultipleNodes =
      r'<h2>Error Report</h2>'
      r'<p>Exception: <code>\App\DB\Exception\NotFound</code></p>'
      r'<p>Stack: <code>\App\Router\Dispatcher::dispatch()</code></p>';
  static const String backslashAndLink =
      r'<p>Exception: <code>\App\DB\Exception\AuthFailed</code>.</p>'
      '<p>See <a href="https://docs.example.com/errors">docs</a> for fix.</p>';
  static const String windowsPathInCode =
      r'<p>File: <code>C:\Users\Admin\AppData\Local\Temp\error.log</code></p>';
  static const String goPathInCode =
      r'<p>FAILED: <code>\github.com\org\repo\pkg\handler\main.go</code></p>';

  // bare \XX text nodes — see skipped test for known limitation
  static const String allHexBackslashParagraphs =
      r'<p>Path: \AB\CD\EF</p>'
      r'<p>Config: \01\23\45</p>';

  // ─── XSS ───────────────────────────────────────────────────────────────────
  static const String xssRich =
      '<div>'
      '<script>document.cookie="stolen";</script>'
      '<img src=x onerror="alert(1)">'
      '<svg><script>alert(\'svg\')</script></svg>'
      '<a href="javascript:void(0)" onclick="alert(1)">Click</a>'
      '<p style="background: url(\'javascript:alert(1)\')">Styled</p>'
      '<p onmouseover="alert(1)">Hover me</p>'
      '<p>Valid content.</p>'
      '</div>';

  // ─── Deeply nested / structural ────────────────────────────────────────────
  static const String deeplyNested =
      '<div><section><article><aside>'
      '<p><strong><em><span style="color:red">deeply nested</span></em></strong></p>'
      '</aside></article></section></div>';

  // ─── Multi-language ────────────────────────────────────────────────────────
  static const String rtlArabic =
      '<div dir="rtl"><p>مرحبا بالعالم</p><p>البريد الإلكتروني</p></div>';
  static const String cjk =
      '<div><p>日本語: メールクライアント</p><p>中文: 电子邮件客户端</p></div>';
}
