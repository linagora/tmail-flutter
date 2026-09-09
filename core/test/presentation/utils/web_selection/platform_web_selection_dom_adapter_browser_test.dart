@TestOn('chrome')

import 'dart:async';
import 'dart:js_interop';

import 'package:core/presentation/utils/web_selection/platform_web_selection_dom_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  late PlatformWebSelectionDomAdapter adapter;
  late List<web.Element> fixtures;

  setUp(() {
    adapter = PlatformWebSelectionDomAdapter();
    fixtures = [];
  });

  tearDown(() {
    adapter.removeTopWindowBlurListener();
    for (final fixture in fixtures.reversed) {
      fixture.remove();
    }
  });

  Future<web.HTMLIFrameElement> appendIframe({
    web.Element? parent,
    bool sandboxed = false,
  }) async {
    final iframe = web.HTMLIFrameElement();
    if (sandboxed) {
      iframe.setAttribute('sandbox', '');
    }

    final loaded = Completer<void>();
    late JSFunction loadListener;
    loadListener = ((web.Event _) {
      iframe.removeEventListener('load', loadListener);
      loaded.complete();
    }).toJS;
    iframe.addEventListener('load', loadListener);
    iframe.srcdoc = '<p id="target">iframe selection</p>'.toJS;
    (parent ?? web.document.body)!.append(iframe);
    fixtures.add(iframe);
    await loaded.future;
    return iframe;
  }

  web.Selection selectIframeText(web.HTMLIFrameElement iframe) {
    final iframeDocument = iframe.contentDocument!;
    final target = iframeDocument.querySelector('#target')!;
    final selection = iframe.contentWindow!.getSelection()!;
    final range = iframeDocument.createRange()..selectNodeContents(target);
    selection
      ..removeAllRanges()
      ..addRange(range);
    return selection;
  }

  web.HTMLElement appendFlutterView() {
    final flutterView =
        web.document.createElement('flutter-view') as web.HTMLElement;
    flutterView.tabIndex = 0;
    web.document.body!.append(flutterView);
    fixtures.add(flutterView);
    return flutterView;
  }

  test('clears a same-origin srcdoc iframe selection', () async {
    final iframe = await appendIframe();
    final selection = selectIframeText(iframe);
    expect(selection.rangeCount, 1);

    adapter.clearIframeSelections();

    expect(selection.rangeCount, 0);
  });

  test('clears selections from every iframe', () async {
    final firstIframe = await appendIframe();
    final secondIframe = await appendIframe();
    final firstSelection = selectIframeText(firstIframe);
    final secondSelection = selectIframeText(secondIframe);

    adapter.clearIframeSelections();

    expect(firstSelection.rangeCount, 0);
    expect(secondSelection.rangeCount, 0);
  });

  test('returns active iframe focus to its enclosing Flutter view', () async {
    final flutterView = appendFlutterView();
    final iframe = await appendIframe(parent: flutterView);
    iframe.focus();
    expect(web.document.activeElement, same(iframe));

    adapter.clearIframeSelections();

    expect(web.document.activeElement, same(flutterView));
  });

  test('blurs an active iframe without an enclosing Flutter view', () async {
    final iframe = await appendIframe();
    iframe.focus();
    expect(web.document.activeElement, same(iframe));

    adapter.clearIframeSelections();

    expect(web.document.activeElement, isNot(same(iframe)));
  });

  test('reports whether an iframe owns top-level focus', () async {
    final flutterView = appendFlutterView()..focus();
    final iframe = await appendIframe(parent: flutterView);
    expect(adapter.isIframeFocused, isFalse);

    iframe.focus();
    expect(adapter.isIframeFocused, isTrue);

    flutterView.focus();
    expect(adapter.isIframeFocused, isFalse);
  });

  test('defends against cross-origin iframe selection access', () async {
    final flutterView = appendFlutterView();
    final iframe = await appendIframe(parent: flutterView, sandboxed: true);
    iframe.focus();
    expect(web.document.activeElement, same(iframe));
    expect(() => iframe.contentWindow!.getSelection(), throwsA(anything));

    expect(adapter.clearIframeSelections, returnsNormally);
    expect(web.document.activeElement, same(flutterView));
  });

  test('replaces and removes the top-window blur listener', () {
    var firstCalls = 0;
    var secondCalls = 0;
    adapter.addTopWindowBlurListener(() => firstCalls++);
    adapter.addTopWindowBlurListener(() => secondCalls++);

    web.window.dispatchEvent(web.Event('blur'));

    expect(firstCalls, 0);
    expect(secondCalls, 1);

    adapter.removeTopWindowBlurListener();
    adapter.removeTopWindowBlurListener();
    web.window.dispatchEvent(web.Event('blur'));

    expect(firstCalls, 0);
    expect(secondCalls, 1);
  });

  test('handles an empty or changing iframe collection', () async {
    expect(adapter.clearIframeSelections, returnsNormally);

    final detachedIframe = await appendIframe();
    selectIframeText(detachedIframe);
    detachedIframe.remove();

    final connectedIframe = await appendIframe();
    final connectedSelection = selectIframeText(connectedIframe);

    expect(adapter.clearIframeSelections, returnsNormally);
    expect(connectedSelection.rangeCount, 0);
  });
}
