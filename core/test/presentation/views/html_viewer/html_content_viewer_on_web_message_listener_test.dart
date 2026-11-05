@TestOn('chrome')

import 'dart:async';
import 'dart:convert';
import 'dart:ui_web' as ui_web;

import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_html/html.dart' as html;

/// A viewer acts only on the messages its own iframe posts: the view id is
/// readable inside the frame, so it cannot prove where a message came from.
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
    'SHOULD forward a link click posted by its own iframe',
    _expectOwnLinkClickForwarded,
  );

  testWidgets(
    'SHOULD NOT forward a link click forged by the app window with its view id',
    _expectHostWindowForgeryIgnored,
  );

  testWidgets(
    'SHOULD NOT forward a link click posted by another iframe with its view id',
    _expectOtherIframeForgeryIgnored,
  );
}

const _ownUrl = 'https://own.example/a';
const _otherUrl = 'https://other.example/b';
const _wait = Duration(seconds: 5);
const _settle = Duration(milliseconds: 500);

const _plainLink = '<a href="$_ownUrl">link</a>';

const _ownLinkClick = '''
<a id="l" href="$_ownUrl">link</a>
<script>
  window.addEventListener('load', () => setTimeout(
    () => document.getElementById('l').click(), 0));
</script>''';

/// Pumps a viewer that records its link clicks and returns its view id,
/// read back from the loaded document because it is random per widget.
Future<String> _pumpViewer(
  WidgetTester tester, {
  required String contentHtml,
  required void Function(Uri?) onClick,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 400,
        height: 400,
        child: HtmlContentViewerOnWeb(
          contentHtml: contentHtml,
          widthContent: 390,
          onClickHyperLinkAction: onClick,
        ),
      ),
    ),
  );
  await tester.pump();
  // The platform view controller initializes on the real event loop.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
  _attachFrameToDocument(tester);
  final document =
      tester.widget<HtmlIframeWidget>(find.byType(HtmlIframeWidget)).srcdoc!;
  return RegExp(r'"view": "([^"]+)"').firstMatch(document)!.group(1)!;
}

/// The test embedder leaves the platform view out of the document.
void _attachFrameToDocument(WidgetTester tester) {
  final platformViewId = tester
      .widget<PlatformViewSurface>(find.byType(PlatformViewSurface))
      .controller
      .viewId;
  final iframe = ui_web.platformViewRegistry.getViewById(platformViewId)
      as html.IFrameElement;
  if (iframe.isConnected != true) {
    html.document.body!.append(iframe);
    addTearDown(iframe.remove);
  }
}

/// The load handshake and a link click, as the frame's own bridge posts them.
List<Map<String, String>> _forgedMessages(String viewId) => [
      {'view': viewId, 'message': 'iframeHasBeenLoaded'},
      {'view': viewId, 'type': 'toDart: onClickHyperLink', 'url': _otherUrl},
    ];

Future<void> _expectOwnLinkClickForwarded(WidgetTester tester) async {
  // Sync, because a fake-async microtask would wait for a pump during runAsync.
  final click = Completer<Uri?>.sync();

  await _pumpViewer(tester, contentHtml: _ownLinkClick, onClick: click.complete);

  expect(
    await tester.runAsync(() => click.future.timeout(_wait)),
    Uri.parse(_ownUrl),
  );
}

Future<void> _expectHostWindowForgeryIgnored(WidgetTester tester) async {
  final clicks = <Uri?>[];
  final viewId =
      await _pumpViewer(tester, contentHtml: _plainLink, onClick: clicks.add);

  for (final message in _forgedMessages(viewId)) {
    html.window.postMessage(jsonEncode(message), '*');
  }
  await tester.runAsync(() => Future<void>.delayed(_settle));

  expect(clicks, isEmpty);
}

Future<void> _expectOtherIframeForgeryIgnored(WidgetTester tester) async {
  final clicks = <Uri?>[];
  final viewId =
      await _pumpViewer(tester, contentHtml: _plainLink, onClick: clicks.add);

  final attacker = html.IFrameElement()
    ..setAttribute('sandbox', 'allow-scripts')
    ..srcdoc = '<script>for (const m of ${jsonEncode(_forgedMessages(viewId))}) '
        'window.parent.postMessage(JSON.stringify(m), "*");</script>';
  html.document.body!.append(attacker);
  addTearDown(attacker.remove);
  await tester.runAsync(() => Future<void>.delayed(_settle));

  expect(clicks, isEmpty);
}
