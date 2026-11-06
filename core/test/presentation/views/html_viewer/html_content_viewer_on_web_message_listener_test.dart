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

  testWidgets(
    'SHOULD measure height after a later load handler grows the body',
    _expectHeightMeasuredAfterLaterLoadGrowth,
  );

  testWidgets(
    'SHOULD size a signature preview WHEN its frame is laid out after load',
    _expectSignatureSizedAfterLateLayout,
  );

  testWidgets(
    'SHOULD report a zero height WHEN the signature is empty',
    _expectEmptySignatureReportsZero,
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

/// The test embedder leaves the platform view out of the document. Layout is
/// flushed so the frame has a viewport when its load handlers measure it.
void _attachFrameToDocument(WidgetTester tester) {
  final iframe = _viewerFrame(tester);
  if (iframe.isConnected != true) {
    html.document.body!.append(iframe);
    iframe.getBoundingClientRect();
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

  final expected = _forgedMessages(viewId).map(jsonEncode).toSet();
  final seen = <String>{};
  final subscription = html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is String && expected.contains(data)) seen.add(data);
  });
  addTearDown(subscription.cancel);

  final attacker = html.IFrameElement()
    ..setAttribute('sandbox', 'allow-scripts')
    ..srcdoc = '<script>for (const m of ${jsonEncode(_forgedMessages(viewId))}) '
        'window.parent.postMessage(JSON.stringify(m), "*");</script>';
  html.document.body!.append(attacker);
  addTearDown(attacker.remove);
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(_wait);
    while (seen.length < expected.length) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          'attacker frame never delivered forged messages',
          _wait,
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });

  expect(clicks, isEmpty);
}

/// A short body, then a load listener registered after the viewer's own
/// (from DOMContentLoaded, once the bridge script has subscribed) that
/// appends a tall block. Height must be read after that listener.
const _growsAfterViewerLoadHandler = '''
<p>short</p>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    window.addEventListener('load', function () {
      var tall = document.createElement('div');
      tall.style.height = '800px';
      document.body.appendChild(tall);
      window.parent.postMessage('grew', '*');
    });
  });
</script>
''';

Future<void> _expectHeightMeasuredAfterLaterLoadGrowth(
  WidgetTester tester,
) async {
  final received = <String>[];
  final subscription = html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is String) received.add(data);
  });
  addTearDown(subscription.cancel);

  await tester.pumpWidget(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 400,
        height: 1200,
        child: HtmlContentViewerOnWeb(
          contentHtml: _growsAfterViewerLoadHandler,
          widthContent: 390,
          autoAdjustHeight: true,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
  _attachFrameToDocument(tester);

  final height = await tester.runAsync(() async {
    final deadline = DateTime.now().add(_wait);
    while (true) {
      final grewAt = received.indexOf('grew');
      final heightAt = received.lastIndexWhere(
        (message) => message.contains('"type":"toDart: htmlHeight"'),
      );
      if (grewAt != -1 && heightAt > grewAt) {
        final message = jsonDecode(received[heightAt]) as Map<String, dynamic>;
        return message['height'] as num;
      }
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          grewAt == -1
              ? 'timed out waiting for the body to grow'
              : 'timed out waiting for htmlHeight measured after the body grew',
          _wait,
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });

  expect(height, greaterThan(500));
}

/// Pumps a viewer configured like the signature preview and returns its view id.
Future<String> _pumpSignatureViewer(
  WidgetTester tester,
  String contentHtml,
) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 400,
        height: 400,
        child: HtmlContentViewerOnWeb(
          contentHtml: contentHtml,
          widthContent: 390,
          contentPadding: 0,
          htmlContentMinHeight: 0,
          offsetHtmlContentHeight: 0,
          autoAdjustHeight: true,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
  final document =
      tester.widget<HtmlIframeWidget>(find.byType(HtmlIframeWidget)).srcdoc!;
  return RegExp(r'"view": "([^"]+)"').firstMatch(document)!.group(1)!;
}

html.IFrameElement _viewerFrame(WidgetTester tester) {
  final platformViewId = tester
      .widget<PlatformViewSurface>(find.byType(PlatformViewSurface))
      .controller
      .viewId;
  return ui_web.platformViewRegistry.getViewById(platformViewId)
      as html.IFrameElement;
}

/// Records the bridge messages of [viewId] only.
List<Map<String, dynamic>> _recordViewMessages(String viewId) {
  final received = <Map<String, dynamic>>[];
  final subscription = html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is! String || !data.startsWith('{')) return;
    final message = jsonDecode(data) as Map<String, dynamic>;
    if (message['view'] == viewId) received.add(message);
  });
  addTearDown(subscription.cancel);
  return received;
}

Iterable<num> _heights(List<Map<String, dynamic>> received) => received
    .where((m) => m['type'] == 'toDart: htmlHeight')
    .map((m) => m['height'] as num);

Future<void> _waitFor(bool Function() condition, String reason) async {
  final deadline = DateTime.now().add(_wait);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) throw TimeoutException(reason, _wait);
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

bool _loaded(List<Map<String, dynamic>> received) =>
    received.any((m) => m['message'] == 'iframeHasBeenLoaded');

/// A frame with no viewport at load must still be sized once it is laid out.
Future<void> _expectSignatureSizedAfterLateLayout(WidgetTester tester) async {
  final viewId = await _pumpSignatureViewer(tester, '<p>signature</p>');
  final received = _recordViewMessages(viewId);
  final iframe = _viewerFrame(tester);
  iframe.style.display = 'none';
  html.document.body!.append(iframe);
  addTearDown(iframe.remove);

  await tester.runAsync(() async {
    await _waitFor(() => _loaded(received), 'frame never loaded');
    // Lets the load-time measurement run while the frame has no viewport.
    await Future<void>.delayed(_settle);
    expect(_heights(received).where((h) => h > 0), isEmpty);
    iframe.style.display = 'block';
    iframe.getBoundingClientRect();
    await _waitFor(
      () => _heights(received).any((h) => h > 0),
      'no positive htmlHeight after layout',
    );
  });
  await tester.pump();

  expect(_heights(received).last, greaterThan(0));
  final height =
      tester.widget<HtmlIframeWidget>(find.byType(HtmlIframeWidget)).height;
  expect(double.parse(height!), greaterThan(0));
}

/// An empty signature in a laid-out frame still reports, so loading ends.
Future<void> _expectEmptySignatureReportsZero(WidgetTester tester) async {
  final viewId = await _pumpSignatureViewer(tester, '');
  final received = _recordViewMessages(viewId);
  _attachFrameToDocument(tester);

  await tester.runAsync(() => _waitFor(
        () => _heights(received).isNotEmpty,
        'empty signature never reported a height',
      ));

  expect(_heights(received).first, 0);
}
