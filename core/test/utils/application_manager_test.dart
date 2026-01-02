import 'package:core/utils/application_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'application_manager_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DeviceInfoPlugin>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late ApplicationManager applicationManager;

  setUp(() {
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    ApplicationManager.debugDeviceInfoOverride = mockDeviceInfoPlugin;

    applicationManager = ApplicationManager();
    applicationManager.clearCache();
  });

  tearDown(() {
    ApplicationManager.debugDeviceInfoOverride = null;
    PlatformInfo.isTestingForWeb = false;
    debugDefaultTargetPlatformOverride = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('fk_user_agent'),
      null,
    );

    FkUserAgent.release();
  });

  group('ApplicationManager::getUserAgent', () {
    test(
      'WHEN platform is Web THEN return web userAgent AND cache it',
      () async {
        const webUserAgent = 'User-Agent-Twake-Mail-Web';

        PlatformInfo.isTestingForWeb = true;

        when(mockDeviceInfoPlugin.webBrowserInfo).thenAnswer(
          (_) async => WebBrowserInfo(
            userAgent: webUserAgent,
            appCodeName: '',
            appName: '',
            appVersion: '',
            deviceMemory: null,
            language: '',
            languages: const [],
            platform: '',
            product: '',
            productSub: '',
            vendor: '',
            vendorSub: '',
            maxTouchPoints: null,
            hardwareConcurrency: null,
          ),
        );

        final firstCall = await applicationManager.getUserAgent();
        final secondCall = await applicationManager.getUserAgent();

        expect(firstCall, webUserAgent);
        expect(secondCall, webUserAgent);

        // platform channel must be called only once (cached)
        verify(mockDeviceInfoPlugin.webBrowserInfo).called(1);
      },
    );

    test(
      'WHEN platform is Android THEN return mobile userAgent AND cache it',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        const androidUserAgent = 'User-Agent-Twake-Mail-Android';

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('fk_user_agent'),
          (message) async {
            if (message.method == 'getProperties') {
              return {'userAgent': androidUserAgent};
            }
            return null;
          },
        );

        await applicationManager.initUserAgent();

        final firstCall = await applicationManager.getUserAgent();
        final secondCall = await applicationManager.getUserAgent();

        expect(firstCall, androidUserAgent);
        expect(secondCall, androidUserAgent);
      },
    );

    test(
      'WHEN platform is Web AND webBrowserInfo throws exception THEN return empty string',
      () async {
        PlatformInfo.isTestingForWeb = true;

        when(mockDeviceInfoPlugin.webBrowserInfo).thenAnswer(
          (_) => Future<WebBrowserInfo>.error(
            Exception('Failed to get web browser info'),
          ),
        );

        final userAgent = await applicationManager.getUserAgent();

        expect(userAgent, '');
      },
    );

    test(
      'WHEN platform is Android AND FkUserAgent returns empty THEN return empty string',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('fk_user_agent'),
          (message) async {
            if (message.method == 'getProperties') {
              return {};
            }
            return null;
          },
        );

        await applicationManager.initUserAgent();

        final userAgent = await applicationManager.getUserAgent();

        expect(userAgent, '');
      },
    );

    test(
      'WHEN mobile userAgent is released THEN getUserAgent returns empty string',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        const androidUserAgent = 'User-Agent-Twake-Mail-Android';

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('fk_user_agent'),
          (message) async {
            if (message.method == 'getProperties') {
              return {'userAgent': androidUserAgent};
            }
            return null;
          },
        );

        await applicationManager.initUserAgent();

        final firstCall = await applicationManager.getUserAgent();
        await applicationManager.releaseUserAgent();
        final secondCall = await applicationManager.getUserAgent();

        expect(firstCall, androidUserAgent);
        expect(secondCall, '');
      },
    );

    test(
      'WHEN mobile userAgent is released AND re-initialized THEN cache rebuilt',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        const androidUserAgent = 'User-Agent-Twake-Mail-Android';

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('fk_user_agent'),
          (message) async {
            if (message.method == 'getProperties') {
              return {'userAgent': androidUserAgent};
            }
            return null;
          },
        );

        await applicationManager.initUserAgent();
        final firstCall = await applicationManager.getUserAgent();

        await applicationManager.releaseUserAgent();
        await applicationManager.initUserAgent();
        final secondCall = await applicationManager.getUserAgent();

        expect(firstCall, androidUserAgent);
        expect(secondCall, androidUserAgent);
      },
    );
  });
}
