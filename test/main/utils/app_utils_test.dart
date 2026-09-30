import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

void main() {
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
