import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/app_route_tab_environment.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

void main() {
  openAppRouteInNewTabTests();

  group('AppUtils.launchLink', () {
    const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');
    late List<String> launchedUrls;

    setUp(() {
      launchedUrls = [];
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

    testWidgets('launches an https link', (tester) async {
      AppUtils.launchLink('https://example.com');
      await tester.pump();

      expect(launchedUrls, contains('https://example.com'));
    });

    testWidgets('launches a mailto link', (tester) async {
      AppUtils.launchLink('mailto:someone@example.com');
      await tester.pump();

      expect(launchedUrls, contains('mailto:someone@example.com'));
    });

    testWidgets('refuses a javascript: link', (tester) async {
      AppUtils.launchLink('javascript:alert(1)');
      await tester.pump();

      expect(launchedUrls, isEmpty);
    });

    testWidgets('refuses the application\'s own deep-link scheme', (tester) async {
      AppUtils.launchLink('twakemail.mobile://openApp?jmapUrl=https://evil.example');
      await tester.pump();

      expect(launchedUrls, isEmpty);
    });

    testWidgets('refuses a URL that cannot be parsed', (tester) async {
      AppUtils.launchLink('http://[::1');
      await tester.pump();

      expect(launchedUrls, isEmpty);
    });

    testWidgets('refuses a URL without a scheme', (tester) async {
      AppUtils.launchLink('not a url');
      await tester.pump();

      expect(launchedUrls, isEmpty);
    });
  });
}

class _FakeAppRouteTabEnvironment extends AppRouteTabEnvironment {
  _FakeAppRouteTabEnvironment({
    this.web = true,
    this.origin = 'https://mail.example.com',
    this.originThrows = false,
    this.tabOpens = true,
  });

  final bool web;
  final String origin;
  final bool originThrows;
  final bool tabOpens;
  final List<String> tabOpened = [];
  final List<String> launched = [];

  @override
  bool get isWeb => web;

  @override
  String currentOrigin() {
    if (originThrows) throw StateError('no origin');
    return origin;
  }

  @override
  bool openTabKeepingSession(String url) {
    tabOpened.add(url);
    return tabOpens;
  }

  @override
  void launch(String url) => launched.add(url);
}

void _openRoute(
  _FakeAppRouteTabEnvironment environment,
  String url, {
  bool isBasicAuth = true,
}) {
  environment.openInNewTab(url, isBasicAuth: isBasicAuth);
}

void openAppRouteInNewTabTests() {
  const sameOriginUrl = 'https://mail.example.com/#/email/1';

  group('AppRouteTabEnvironment.openInNewTab', () {
    test('web, basic auth, same origin keeps the session and skips launchLink', () {
      final environment = _FakeAppRouteTabEnvironment();
      _openRoute(environment, sameOriginUrl);

      expect(environment.tabOpened, [sameOriginUrl]);
      expect(environment.launched, isEmpty);
    });

    test('falls back to launchLink when the browser refuses the tab', () {
      final environment = _FakeAppRouteTabEnvironment(tabOpens: false);
      _openRoute(environment, sameOriginUrl);

      expect(environment.launched, [sameOriginUrl]);
    });

    final launchLinkCases = <String, _FakeAppRouteTabEnvironment Function()>{
      'not web': () => _FakeAppRouteTabEnvironment(web: false),
      'different origin': () =>
          _FakeAppRouteTabEnvironment(origin: 'https://other.example.com'),
      'origin check throwing': () =>
          _FakeAppRouteTabEnvironment(originThrows: true),
    };
    launchLinkCases.forEach((name, build) {
      test('$name goes through launchLink', () {
        final environment = build();
        _openRoute(environment, sameOriginUrl);

        expect(environment.tabOpened, isEmpty);
        expect(environment.launched, [sameOriginUrl]);
      });
    });

    test('OIDC goes through launchLink', () {
      final environment = _FakeAppRouteTabEnvironment();
      _openRoute(environment, sameOriginUrl, isBasicAuth: false);

      expect(environment.tabOpened, isEmpty);
      expect(environment.launched, [sameOriginUrl]);
    });

    for (final url in ['/email/1', 'null', 'javascript:alert(1)', 'mailto:a@b.c']) {
      test('"$url" goes through launchLink', () {
        final environment = _FakeAppRouteTabEnvironment();
        _openRoute(environment, url);

        expect(environment.tabOpened, isEmpty);
        expect(environment.launched, [url]);
      });
    }
  });
}
