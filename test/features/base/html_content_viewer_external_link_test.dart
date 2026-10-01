import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/ios_html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// The web view packages are reached through `core`, which owns the dependency.
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_inappwebview_platform.dart';

class _FakeInAppWebViewController extends Fake implements InAppWebViewController {}

/// Keeps the creation params so a test can play the navigation callback the
/// native web view would call when the user taps a link.
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

/// Links in the rendered email are untrusted: the viewers must hand only
/// allow-listed schemes to the OS, and report the others as blocked.
void main() {
  const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');
  late List<String> launchedUrls;
  late List<Uri> blockedUris;
  late _CapturingInAppWebViewPlatform webViewPlatform;

  setUp(() {
    webViewPlatform = _CapturingInAppWebViewPlatform();
    InAppWebViewPlatform.instance = webViewPlatform;
    launchedUrls = [];
    blockedUris = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (call) async {
      if (call.method == 'launch' || call.method == 'launchUrl') {
        final arguments = call.arguments as Map<dynamic, dynamic>;
        launchedUrls.add(arguments['url'] as String);
      }
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
  });

  Future<NavigationActionPolicy?> clickLink(
    WidgetTester tester,
    Widget viewer,
    String url,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: viewer)));
    await tester.pump();

    return webViewPlatform.params!.shouldOverrideUrlLoading!(
      _FakeInAppWebViewController(),
      NavigationAction(
        request: URLRequest(url: WebUri(url)),
        isForMainFrame: true,
      ),
    );
  }

  final viewers = <String, Widget Function()>{
    'HtmlContentViewer': () => HtmlContentViewer(
      configuration: HtmlContentViewerConfiguration(
        content: const HtmlContentViewerContent(html: '<p>Mail</p>'),
        callbacks: HtmlContentViewerCallbacks(onBlockedLink: blockedUris.add),
      ),
    ),
    'IosHtmlContentViewerWidget': () => IosHtmlContentViewerWidget(
      contentHtml: '<p>Mail</p>',
      onBlockedLinkAction: blockedUris.add,
    ),
  };

  viewers.forEach((name, buildViewer) {
    group('$name external links', () {
      testWidgets('SHOULD refuse and report the app\'s own deep-link scheme', (tester) async {
        const url = 'twakemail.mobile://openApp?jmapUrl=https://evil.example';

        final policy = await clickLink(tester, buildViewer(), url);

        expect(policy, NavigationActionPolicy.CANCEL);
        expect(launchedUrls, isEmpty);
        expect(blockedUris, [Uri.parse(url)]);
      });

      testWidgets('SHOULD launch an https link externally', (tester) async {
        final policy = await clickLink(tester, buildViewer(), 'https://example.com/page');

        expect(policy, NavigationActionPolicy.CANCEL);
        expect(launchedUrls, ['https://example.com/page']);
        expect(blockedUris, isEmpty);
      });
    });
  });
}
