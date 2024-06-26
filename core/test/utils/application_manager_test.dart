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

@GenerateNiceMocks([
  MockSpec<DeviceInfoPlugin>()
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late ApplicationManager applicationManager;

  setUp(() {
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    applicationManager = ApplicationManager(mockDeviceInfoPlugin);
  });

  group('ApplicationManager::getUserAgent test', () {
    test('WHEN platform is Web THEN getUserAgent should be return user agent for web', () async {
      const webUserAgent = 'User-Agent-Twake-Mail-Web';

      PlatformInfo.isTestingForWeb = true;

      when(mockDeviceInfoPlugin.webBrowserInfo)
          .thenAnswer((_) async => WebBrowserInfo(
                userAgent: webUserAgent,
                appCodeName: '',
                appName: '',
                appVersion: '',
                deviceMemory: null,
                language: '',
                languages: [],
                platform: '',
                product: '',
                productSub: '',
                vendor: '',
                vendorSub: '',
                maxTouchPoints: null,
                hardwareConcurrency: null,
              ));

      final userAgent = await applicationManager.getUserAgent();

      expect(userAgent, webUserAgent);

      PlatformInfo.isTestingForWeb = false;
    });

    test('WHEN platform is Android THEN getUserAgent should be return user agent for Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      const androidUserAgent = 'User-Agent-Twake-Mail-Android';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('fk_user_agent'),
        (message) async {
          if (message.method == 'getProperties') {
            return {
              'userAgent': androidUserAgent
            };
          }
          return null;
        }
      );

      await FkUserAgent.init();

      final userAgent = await applicationManager.getUserAgent();

      expect(userAgent, androidUserAgent);

      debugDefaultTargetPlatformOverride = null;
      FkUserAgent.release();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('fk_user_agent'),
        null);
    });

    test('WHEN platform is Web\n'
        'AND mockDeviceInfoPlugin.webBrowserInfo throw exception\n'
        'THEN getUserAgent should be return empty string',
    () async {
      PlatformInfo.isTestingForWeb = true;

      when(mockDeviceInfoPlugin.webBrowserInfo).thenThrow(Exception('Failed to get web browser info'));

      final userAgent = await applicationManager.getUserAgent();

      expect(userAgent, '');

      PlatformInfo.isTestingForWeb = false;
    });

    test('WHEN platform is Android\n'
        'AND FkUserAgent.userAgent return empty string\n'
        'THEN getUserAgent should be return empty string',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('fk_user_agent'),
        (message) async {
          if (message.method == 'getProperties') {
            return {};
          }
          return null;
        }
      );

      await FkUserAgent.init();

      final userAgent = await applicationManager.getUserAgent();

      expect(userAgent, '');

      debugDefaultTargetPlatformOverride = null;
      FkUserAgent.release();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('fk_user_agent'),
        null);
    });
  });
}
