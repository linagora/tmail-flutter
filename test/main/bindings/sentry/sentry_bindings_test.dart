import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/sentry_session_cleanup.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/sentry_ecosystem.dart';
import 'package:tmail_ui_user/main/bindings/sentry/sentry_bindings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    Get.reset();
  });

  test('registers one app-lifetime instance for both Sentry contracts', () {
    SentryBindings().dependencies();

    final sentryEcosystem = Get.find<SentryEcosystem>();
    final sessionCleanup = Get.find<SentrySessionCleanup>();

    expect(identical(sentryEcosystem, sessionCleanup), isTrue);
  });

  test('keeps the same Sentry instance when bindings run again', () {
    SentryBindings().dependencies();
    final firstInstance = Get.find<SentryEcosystem>();

    SentryBindings().dependencies();

    expect(Get.find<SentryEcosystem>(), same(firstInstance));
    expect(Get.find<SentrySessionCleanup>(), same(firstInstance));
  });
}
