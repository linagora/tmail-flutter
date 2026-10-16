@TestOn('chrome')

import 'dart:convert';

import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_html/html.dart' as html;

/// Every viewer listens on the same window, so each one must act only on the
/// messages its own iframe posts.
void main() {
  testWidgets(
    'SHOULD forward a link click posted by its own iframe',
    _expectOwnLinkClickForwarded,
  );

  testWidgets(
    'SHOULD NOT forward a link click posted by another viewer iframe',
    _expectOtherViewLinkClickIgnored,
  );
}

const _ownUrl = 'https://own.example/a';
const _otherUrl = 'https://other.example/b';

/// Pumps a viewer that records its link clicks and returns its view id,
/// read back from the loaded document because it is random per widget.
Future<String> _pumpViewer(WidgetTester tester, List<Uri?> clicks) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: HtmlContentViewerOnWeb(
        contentHtml: '<a href="$_ownUrl">link</a>',
        widthContent: 390,
        onClickHyperLinkAction: clicks.add,
      ),
    ),
  ));
  await tester.pump();
  final document = tester.widget<HtmlIframeWidget>(find.byType(HtmlIframeWidget)).srcdoc!;
  return RegExp(r'"view": "([^"]+)"').firstMatch(document)!.group(1)!;
}

/// Posts [message] to the window the viewer listens on and lets the browser
/// deliver it.
Future<void> _post(WidgetTester tester, Map<String, String> message) async {
  html.window.postMessage(jsonEncode(message), '*');
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
}

Future<void> _postLinkClick(WidgetTester tester, {required String view, required String url}) async {
  await _post(tester, {'view': view, 'message': 'iframeHasBeenLoaded'});
  await _post(tester, {'view': view, 'type': 'toDart: onClickHyperLink', 'url': url});
}

Future<void> _expectOwnLinkClickForwarded(WidgetTester tester) async {
  final clicks = <Uri?>[];
  final viewId = await _pumpViewer(tester, clicks);

  await _postLinkClick(tester, view: viewId, url: _ownUrl);

  expect(clicks, [Uri.parse(_ownUrl)]);
}

Future<void> _expectOtherViewLinkClickIgnored(WidgetTester tester) async {
  final clicks = <Uri?>[];
  final viewId = await _pumpViewer(tester, clicks);

  await _postLinkClick(tester, view: '${viewId}x', url: _otherUrl);

  expect(clicks, isEmpty);
}
