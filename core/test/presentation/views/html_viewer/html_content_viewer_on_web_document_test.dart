@TestOn('chrome')

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:core/presentation/views/shortcut/key_shortcut.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The viewer document locks build documents from chosen inputs; these tests
/// pin that [HtmlContentViewerOnWeb] passes its own options to the builder
/// and loads exactly that document into the iframe.
void main() {
  testWidgets(
    'SHOULD load the document built from every callback and option it is given',
    _expectDocumentWithEveryOption,
  );

  testWidgets(
    'SHOULD leave out the scripts of callbacks and options it is not given',
    _expectDocumentWithoutOptions,
  );

  testWidgets('SHOULD sandbox the iframe it renders mail in', (tester) async {
    await _loadedDocument(
      tester,
      const HtmlContentViewerOnWeb(contentHtml: _html, widthContent: 390),
    );

    expect(
      tester.widget<HtmlIframeWidget>(find.byType(HtmlIframeWidget)).sandbox,
      HtmlIframeWidget.sandboxPolicy,
    );
  });

  test('SHOULD run its bridge without reading the parent window', () {
    final document = HtmlViewerDocumentBuilder.buildWebDocument(
      const HtmlWebViewerDocumentInput(
        content: _html,
        viewId: 'view1',
        widthContent: 390,
        minHeight: 100,
        minWidth: 100,
      ),
    );

    expect(document, contains("window.addEventListener('message', handleMessage"));
    expect(document, contains('toIframe: clearSelection'));
    expect(document, contains('e.source !== window.parent'));
    expect(document, isNot(contains('window.parent.addEventListener')));
    expect(document, isNot(contains('window.parent.removeEventListener')));
    expect(document, isNot(contains('getHeight')));
    expect(document, isNot(contains('getWidth')));
    expect(document, isNot(contains('execCommand')));
  });
}

const _html = '<p>مرحبا</p><blockquote><p>quoted</p></blockquote>';

Future<String> _loadedDocument(WidgetTester tester, HtmlContentViewerOnWeb viewer) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: viewer)));
  await tester.pump();
  return tester.widget<HtmlIframeWidget>(find.byType(HtmlIframeWidget)).srcdoc!;
}

/// The view id is random per widget, so it is read back from the document.
String _viewIdOf(String document) =>
    RegExp(r'"view": "([^"]+)"').firstMatch(document)!.group(1)!;

Future<void> _expectDocumentWithEveryOption(WidgetTester tester) async {
  final document = await _loadedDocument(
    tester,
    HtmlContentViewerOnWeb(
      contentHtml: _html,
      widthContent: 760,
      direction: TextDirection.rtl,
      contentPadding: 12,
      useDefaultFontStyle: true,
      fontSize: 15,
      mailtoDelegate: (_) {},
      onClickHyperLinkAction: (_) {},
      onIFrameKeyboardShortcutAction: (KeyShortcut _) {},
      scrollController: ScrollController(),
      enableQuoteToggle: true,
      disableScrolling: true,
      useLinkTooltipOverlay: true,
      htmlContentMinHeight: 120,
      htmlContentMinWidth: 280,
    ),
  );

  expect(
    document,
    HtmlViewerDocumentBuilder.buildWebDocument(
      HtmlWebViewerDocumentInput(
        content: _html,
        viewId: _viewIdOf(document),
        widthContent: 760,
        minHeight: 120,
        minWidth: 280,
        direction: TextDirection.rtl,
        contentPadding: 12,
        useDefaultFontStyle: true,
        fontSize: 15,
        enableQuoteToggle: true,
        disableScrolling: true,
        hasMailtoDelegate: true,
        hasHyperLinkAction: true,
        hasScrollController: true,
        hasKeyboardShortcutAction: true,
        useLinkTooltipOverlay: true,
        isWebTouchDevice: PlatformInfo.isWebTouchDevice,
        isWebDesktop: PlatformInfo.isWebDesktop,
      ),
    ),
  );
}

Future<void> _expectDocumentWithoutOptions(WidgetTester tester) async {
  final document = await _loadedDocument(
    tester,
    const HtmlContentViewerOnWeb(
      contentHtml: _html,
      widthContent: 390,
      autoAdjustHeight: true,
    ),
  );

  expect(
    document,
    HtmlViewerDocumentBuilder.buildWebDocument(
      HtmlWebViewerDocumentInput(
        content: _html,
        viewId: _viewIdOf(document),
        widthContent: 390,
        minHeight: ConstantsUI.htmlContentMinHeight,
        minWidth: ConstantsUI.htmlContentMinWidth,
        autoAdjustHeight: true,
        isWebTouchDevice: PlatformInfo.isWebTouchDevice,
        isWebDesktop: PlatformInfo.isWebDesktop,
      ),
    ),
  );
}
