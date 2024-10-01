import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWebViewPlatform extends InAppWebViewPlatform with MockPlatformInterfaceMixin {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) => MockWebViewWidget.implementation(params);

  @override
  PlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) => MockPlatformCookieManager();
}

class MockPlatformCookieManager extends Fake implements PlatformCookieManager {
  @override
  Future<bool> deleteAllCookies() async {
    return true;
  }

  @override
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = '/',
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    return true;
  }
}

class MockWebViewWidget extends PlatformInAppWebViewWidget {
  MockWebViewWidget.implementation(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}
