import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/mobile_composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/web_composer_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_session_cache_datasource_impl.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

class _MockComposerController extends Mock implements ComposerController {
  ComposerReloadCacheAction? registeredReloadCacheAction;

  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});

  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});

  @override
  void registerReloadCacheAction(ComposerReloadCacheAction action) {
    registeredReloadCacheAction = action;
  }
}

class _TestComposerView extends ComposerView {
  const _TestComposerView();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test(
    'registers native composer dependencies with the default GetX tag',
    () {
      ComposerBindings().dependencies();

      expect(Get.isPrepared<ComposerController>(), isTrue);
      expect(Get.isPrepared<ComposerController>(tag: 'tablet-composer'), isFalse);
    },
  );

  testWidgets(
    'ComposerView resolves the native composer controller without a tag',
    (tester) async {
      final controller = _MockComposerController();
      const view = _TestComposerView();
      Get.lazyPut<ComposerController>(() => controller);

      await tester.pumpWidget(const GetMaterialApp(home: view));

      expect(tester.takeException(), isNull);
      expect(view.controller, same(controller));
    },
  );

  test('registers reload cache handler only from web bindings', () {
    const webComposerId = 'web-composer';
    final webController = _MockComposerController();
    final mobileController = _MockComposerController();
    Get.put<ComposerSessionCacheDatasourceImpl>(
      ComposerSessionCacheDatasourceImpl(CacheExceptionThrower()),
      tag: webComposerId,
    );

    WebComposerBindings(composerId: webComposerId)
        .registerPlatformReloadCacheHandler(webController);
    MobileComposerBindings(composerId: 'mobile-composer')
        .registerPlatformReloadCacheHandler(mobileController);

    expect(webController.registeredReloadCacheAction, isNotNull);
    expect(mobileController.registeredReloadCacheAction, isNull);
  });
}
