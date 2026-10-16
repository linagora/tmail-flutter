import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:core/presentation/views/html_viewer/ios_html_content_viewer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// The web view packages are reached through `core`, which owns the dependency.
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_inappwebview_platform.dart';

/// Records the document a viewer loads into its web view.
class _DocumentCapturingController extends Fake implements InAppWebViewController {
  final List<String> loadedData = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #loadData) {
      loadedData.add(invocation.namedArguments[#data] as String);
      return Future<void>.value();
    }
    if (invocation.memberName == #addJavaScriptHandler) return null;
    return super.noSuchMethod(invocation);
  }
}

class _CapturingInAppWebViewPlatform extends FakeInAppWebViewPlatform {
  PlatformInAppWebViewWidgetCreationParams? params;

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    this.params = params;
    return super.createPlatformInAppWebViewWidget(params);
  }
}

/// The viewer document locks build documents from chosen inputs; these tests
/// pin that each viewer widget passes its own options and platform to the
/// builder, and loads exactly that document.
void main() {
  late _CapturingInAppWebViewPlatform webViewPlatform;

  setUp(() {
    webViewPlatform = _CapturingInAppWebViewPlatform();
    InAppWebViewPlatform.instance = webViewPlatform;
  });

  Future<List<String>> loadedDocuments(WidgetTester tester, Widget viewer) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: viewer)));
    await tester.pump();

    final controller = _DocumentCapturingController();
    webViewPlatform.params!.onWebViewCreated!(controller);
    await tester.pump();
    return controller.loadedData;
  }

  HtmlContentViewerConfiguration emailConfiguration() =>
      HtmlContentViewerConfiguration(
        content: const HtmlContentViewerContent(
          html: '<p>مرحبا</p><blockquote><p>quoted</p></blockquote>',
          direction: TextDirection.rtl,
        ),
        layout: const HtmlContentViewerLayout(
          viewport: HtmlContentViewerViewport(
            constraints: BoxConstraints.tightFor(width: 390),
          ),
          contentPadding: HtmlContentViewerLength(12),
        ),
        typography: const HtmlContentViewerTypography(
          fontStyle: HtmlContentViewerFontStyle.defaultStyle,
          textSize: HtmlContentViewerLength(15),
        ),
        behavior: HtmlContentViewerBehavior(features: {
          HtmlContentViewerFeature.quoteToggle,
          HtmlContentViewerFeature.mobileResponsiveLayout,
        }),
      );

  testWidgets(
    'HtmlContentViewer SHOULD load the native document built for its configuration and platform',
    (tester) async {
      final platform = defaultTargetPlatform;

      final documents = await loadedDocuments(
        tester,
        HtmlContentViewer(configuration: emailConfiguration()),
      );

      expect(documents, [
        HtmlViewerDocumentBuilder.buildNativeDocument(
          configuration: emailConfiguration(),
          platform: platform == TargetPlatform.macOS
              ? HtmlContentViewerPlatform.desktop
              : HtmlContentViewerPlatform.mobile,
          isAndroid: platform == TargetPlatform.android,
        ),
      ]);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }),
  );

  testWidgets(
    'IosHtmlContentViewerWidget SHOULD load the iOS document built for its options',
    (tester) async {
      const html = '<p>مرحبا</p>';

      final documents = await loadedDocuments(
        tester,
        const IosHtmlContentViewerWidget(
          contentHtml: html,
          direction: TextDirection.rtl,
          useDefaultFontStyle: false,
        ),
      );

      expect(documents, [
        HtmlViewerDocumentBuilder.buildIosDocument(
          content: html,
          direction: TextDirection.rtl,
          useDefaultFontStyle: false,
        ),
      ]);
    },
  );
}
