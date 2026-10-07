@TestOn('vm')

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_lock_golden.dart';

/// Locks the full HTML document each email viewer loads (scripts, styles,
/// template), built with the email view's own options. A change to a viewer
/// script, the document template or the builders fails here with a diff.
void main() {
  const inputs = <String, (String, TextDirection?)>{
    'plain': ('<p>Hello <b>world</b></p>', null),
    'quote': (
      '<div>Reply</div>'
          '<blockquote><p>quoted</p><blockquote><p>nested</p></blockquote></blockquote>',
      null,
    ),
    'rtl': ('<p>مرحبا بالعالم</p>', TextDirection.rtl),
  };

  HtmlContentViewerConfiguration nativeEmailConfiguration(
    String html,
    TextDirection? direction,
  ) => HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: html, direction: direction),
        layout: const HtmlContentViewerLayout(
          viewport: HtmlContentViewerViewport(
            constraints: BoxConstraints.tightFor(width: 390),
          ),
          contentPadding: HtmlContentViewerLength(0),
        ),
        typography: const HtmlContentViewerTypography(
          fontStyle: HtmlContentViewerFontStyle.defaultStyle,
          textSize: HtmlContentViewerLength(16),
        ),
        behavior: HtmlContentViewerBehavior(features: {
          HtmlContentViewerFeature.keepAlive,
          HtmlContentViewerFeature.quoteToggle,
          HtmlContentViewerFeature.mobileResponsiveLayout,
        }),
      );

  final expectedFiles = <String>{};

  inputs.forEach((name, input) {
    final (html, direction) = input;

    for (final isAndroid in [true, false]) {
      final file = 'native-${isAndroid ? 'android' : 'ios'}-$name.html';
      expectedFiles.add(file);
      test('native viewer document ($file) is locked', () {
        expectMatchesHtmlLock(
          'viewer_document/$file',
          HtmlViewerDocumentBuilder.buildNativeDocument(
            configuration: nativeEmailConfiguration(html, direction),
            platform: HtmlContentViewerPlatform.mobile,
            isAndroid: isAndroid,
          ),
        );
      });
    }

    final webFile = 'web-$name.html';
    expectedFiles.add(webFile);
    test('web viewer document ($webFile) is locked', () {
      expectMatchesHtmlLock(
        'viewer_document/$webFile',
        HtmlViewerDocumentBuilder.buildWebDocument(
          HtmlWebViewerDocumentInput(
            content: html,
            viewId: 'lockViewId',
            widthContent: 760,
            minHeight: ConstantsUI.htmlContentMinHeight,
            minWidth: ConstantsUI.htmlContentMinWidth,
            direction: direction,
            contentPadding: 0,
            useDefaultFontStyle: true,
            enableQuoteToggle: true,
            hasMailtoDelegate: true,
            hasScrollController: true,
            hasKeyboardShortcutAction: true,
            useLinkTooltipOverlay: true,
            isWebDesktop: true,
          ),
        ),
      );
    });

    final iosFile = 'ios-previewer-$name.html';
    expectedFiles.add(iosFile);
    test('iOS previewer document ($iosFile) is locked', () {
      expectMatchesHtmlLock(
        'viewer_document/$iosFile',
        HtmlViewerDocumentBuilder.buildIosDocument(
          content: html,
          direction: direction,
        ),
      );
    });
  });

  // Other production flag sets, so every script branch has a golden.
  const plain = '<p>Hello <b>world</b></p>';
  final variants = <String, String Function()>{
    'web-previewer-links.html': () => HtmlViewerDocumentBuilder.buildWebDocument(
          const HtmlWebViewerDocumentInput(
            content: plain,
            viewId: 'lockViewId',
            widthContent: 760,
            minHeight: ConstantsUI.htmlContentMinHeight,
            minWidth: ConstantsUI.htmlContentMinWidth,
            hasMailtoDelegate: true,
            hasHyperLinkAction: true,
            isWebDesktop: true,
          ),
        ),
    'web-signature-auto-height.html': () =>
        HtmlViewerDocumentBuilder.buildWebDocument(
          const HtmlWebViewerDocumentInput(
            content: plain,
            viewId: 'lockViewId',
            widthContent: 300,
            minHeight: 0,
            minWidth: 0,
            autoAdjustHeight: true,
            disableScrolling: true,
          ),
        ),
    'web-touch-scroll.html': () => HtmlViewerDocumentBuilder.buildWebDocument(
          const HtmlWebViewerDocumentInput(
            content: plain,
            viewId: 'lockViewId',
            widthContent: 390,
            minHeight: ConstantsUI.htmlContentMinHeight,
            minWidth: ConstantsUI.htmlContentMinWidth,
            hasScrollController: true,
            isWebTouchDevice: true,
          ),
        ),
    'native-desktop-no-width-no-scroll.html': () =>
        HtmlViewerDocumentBuilder.buildNativeDocument(
          configuration: HtmlContentViewerConfiguration(
            content: const HtmlContentViewerContent(html: plain),
            behavior: HtmlContentViewerBehavior(features: {
              HtmlContentViewerFeature.disableScrolling,
              HtmlContentViewerFeature.mobileResponsiveLayout,
            }),
          ),
          platform: HtmlContentViewerPlatform.desktop,
          isAndroid: false,
        ),
  };

  variants.forEach((file, build) {
    expectedFiles.add(file);
    test('viewer document ($file) is locked', () {
      expectMatchesHtmlLock('viewer_document/$file', build());
    });
  });

  test('no viewer document lock is left for a removed case', () {
    expect(orphanHtmlLockFiles('viewer_document', expectedFiles), isEmpty);
  });
}
