// The platform interface is reached through `core`, which owns the dependency.
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter/material.dart';

/// `InAppWebView` asserts that a platform implementation is registered before
/// it builds, and no plugin registers one under `flutter test`. Installing this
/// stub lets the viewer build normally, so a widget test can hold every real
/// exception against the change under test instead of draining them all.
class FakeInAppWebViewPlatform extends InAppWebViewPlatform {

  static void install() =>
      InAppWebViewPlatform.instance = FakeInAppWebViewPlatform();

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) => _FakeInAppWebViewWidget(params);
}

class _FakeInAppWebViewWidget extends PlatformInAppWebViewWidget {

  _FakeInAppWebViewWidget(PlatformInAppWebViewWidgetCreationParams params)
      : super.implementation(params);

  /// The real widget fills whatever box it is given, so the stub must too or
  /// the surrounding layout would be measured against the wrong size.
  @override
  Widget build(BuildContext context) => const SizedBox.expand();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      controller as T;

  @override
  void dispose() {}
}
