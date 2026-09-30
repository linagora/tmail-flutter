@TestOn('chrome')

import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  late web.HTMLDivElement editable;

  setUpAll(() {
    final script = web.HTMLScriptElement()
      ..type = 'text/javascript'
      ..text = HtmlUtils.sanitizeInsertHtml.script;
    web.document.head!.append(script);
  });

  setUp(() {
    editable = web.HTMLDivElement()..contentEditable = 'true';
    web.document.body!.append(editable);
    editable.focus();
  });

  tearDown(() => editable.remove());

  test('insertHTML SHOULD drop event handlers and keep the image', () {
    web.document.execCommand(
      'insertHTML',
      false,
      '<p>Hi</p><img src="https://x/a.png" onerror="window.__xss=1">',
    );

    final html = editable.innerHTML.toString();
    expect(html, contains('Hi'));
    expect(html, contains('https://x/a.png'));
    expect(html, isNot(contains('onerror')));
  });

  test('insertHTML SHOULD drop javascript: links and scripts', () {
    web.document.execCommand(
      'insertHTML',
      false,
      '<a href="javascript:void(0)">x</a><script>window.__xss=2</script>',
    );

    final html = editable.innerHTML.toString();
    expect(html, isNot(contains('javascript:')));
    expect(html, isNot(contains('<script')));
  });
}
