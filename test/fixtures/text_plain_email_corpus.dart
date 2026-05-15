/// Test corpus for plain-text email integration tests.
abstract final class TextPlainEmailCorpus {
  // ─── Simple ────────────────────────────────────────────────────────────────
  static const String simple = 'Hello Alice, how are you today?';
  static const String multiLine = 'Dear Alice,\n\nThank you.\n\nBest regards,\nBob';
  static const String unicode = 'Bonjour 🎉 résumé 日本語 한국어';
  static const String ltGtAmpersand = 'Score: a < b && b > 0';
  static const String withHttpsUrl = 'Read more at https://example.com/docs';
  static const String withEmailAddress = 'Send questions to support@example.com';
  static const String withMultipleUrls =
      'Docs: https://docs.example.com\nAPI: https://api.example.com/v1';

  // ─── XSS in plain text ─────────────────────────────────────────────────────
  static const String scriptTag =
      'Report: <script>document.cookie</script> — please review';
  static const String imgTracker =
      'Click <img src="https://tracker.com/px" onerror="alert(1)"> here';

  // ─── Backslash namespace / path patterns ──────────────────────────────────
  static const String phpNamespace =
      r'Unhandled exception: \App\DB\Exception\AuthFailed — access denied';
  static const String phpStackTrace =
      r'Fatal error: Uncaught \App\Http\Exception\NotFound' '\n'
      r'Stack trace: #0 \App\Router\Dispatcher::dispatch()' '\n'
      'In file: /var/www/html/public/index.php on line 42';
  static const String windowsFilePath =
      r'C:\Users\Admin\AppData\Local\Temp\error.log';
  static const String goPackagePath =
      r'FAILED: \github.com\org\repo\pkg\handler\main.go';
  static const String phpNamespaceWithUrl =
      'On Monday, Alice wrote:\n'
      r"throw new \App\DB\Exception\AuthFailed('access denied');" '\n'
      'See https://jira.example.com/issues/1234 for context.';

  // ─── HTML-special characters ───────────────────────────────────────────────
  static const String ampersand = 'Tom & Jerry';

  // ─── Preformatted / tables ─────────────────────────────────────────────────
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

  // ─── Complex plain text ────────────────────────────────────────────────────
  static const String markdownBody =
      '# Monthly Report\n\n'
      '## Summary\n'
      '- Revenue: \$1.2M (+12%)\n'
      '- Active users: 45,000\n\n'
      '**Key metric:** churn rate down to 3.2%.\n\n'
      'Full dashboard: https://analytics.example.com/may-2026';
  static const String xmlBody =
      'API response:\n'
      '<?xml version="1.0"?>\n'
      '<response><status>200</status><message>OK</message></response>';
  static const String pythonCode =
      'def greet(name: str) -> str:\n'
      '    return f"Hello, {name}!"\n'
      '\n'
      'print(greet("World"))';
  static const String windowsCrlf = 'Line one\r\nLine two\r\nLine three';
  static const String quotedReply =
      'Hi Alice,\n\n'
      '> On Monday you wrote:\n'
      '> Please review https://example.com/pr/42\n\n'
      'Done, looks good!';
}
