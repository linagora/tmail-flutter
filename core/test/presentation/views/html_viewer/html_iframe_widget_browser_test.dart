@TestOn('chrome')

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web/web.dart' as web;

/// Widget tests ignore platform messages, so these tests let them through.
/// MaterialApp is omitted: its system-chrome call leaves a pending timer.
void main() {
  setUp(() {
    ui_web.TestEnvironment.setUp(
      const ui_web.TestEnvironment(
        forceTestFonts: true,
        disableFontFallbacks: true,
        keepSemanticsDisabledOnUpdate: true,
        defaultToTestUrlStrategy: true,
      ),
    );
    addTearDown(
      () => ui_web.TestEnvironment.setUp(
        const ui_web.TestEnvironment.flutterTester(),
      ),
    );
  });

  testWidgets(
    'SHOULD render the mail in a frame that cannot reach the app window',
    (tester) async {
      final messages = StreamController<String>.broadcast();
      final listener = ((web.MessageEvent event) {
        final data = event.data;
        if (data.isA<JSString>()) messages.add((data as JSString).toDart);
      }).toJS;
      web.window.addEventListener('message', listener);
      addTearDown(() {
        web.window.removeEventListener('message', listener);
        messages.close();
      });

      final verdict = messages.stream.firstWhere(
        (message) => message == 'blocked' || message == 'leak',
      );
      final iframe = await _pumpIframe(
        tester,
        sandbox: HtmlIframeWidget.sandboxPolicy,
        srcdoc: HtmlViewerDocumentBuilder.buildWebDocument(
          const HtmlWebViewerDocumentInput(
            content: _probingContent,
            viewId: 'probe',
            widthContent: 390,
            minHeight: 50,
            minWidth: 50,
          ),
        ),
      );
      // The test embedder leaves the platform view out of the document.
      if (iframe.isConnected != true) {
        html.document.body!.append(iframe);
        addTearDown(iframe.remove);
      }

      expect(
        await tester.runAsync(
          () => verdict.timeout(const Duration(seconds: 5)),
        ),
        'blocked',
      );
    },
  );

  testWidgets('SHOULD set the sandbox attribute on the DOM iframe', (
    tester,
  ) async {
    final iframe = await _pumpIframe(
      tester,
      sandbox: HtmlIframeWidget.sandboxPolicy,
    );

    expect(iframe.getAttribute('sandbox'), HtmlIframeWidget.sandboxPolicy);
  });

  testWidgets('SHOULD NOT set the sandbox attribute when sandbox is null', (
    tester,
  ) async {
    final iframe = await _pumpIframe(tester, sandbox: null);

    expect(iframe.getAttribute('sandbox'), isNull);
  });
}

/// Posts `blocked` when the frame cannot read the app window, `leak` when it can.
const _probingContent = '''
<p>fabricated mail</p>
<script>
  try {
    window.parent.document.title;
    window.localStorage.length;
    window.parent.postMessage('leak', '*');
  } catch (e) {
    window.parent.postMessage('blocked', '*');
  }
</script>
''';

const _srcdoc = '<p>fabricated</p>';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(width: 400, height: 400, child: child),
    ),
  );
  await tester.pump();
}

Future<html.IFrameElement> _pumpIframe(
  WidgetTester tester, {
  required String? sandbox,
  String srcdoc = _srcdoc,
}) async {
  final created = Completer<html.IFrameElement>();
  await _pump(
    tester,
    HtmlIframeWidget(
      sandbox: sandbox,
      srcdoc: srcdoc,
      width: '120',
      height: '80',
      onIframeCreated: created.complete,
    ),
  );
  expect(created.isCompleted, isTrue, reason: 'onIframeCreated never ran');
  return created.future;
}
