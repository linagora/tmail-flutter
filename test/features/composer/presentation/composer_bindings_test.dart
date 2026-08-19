import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

class _MockComposerController extends Mock implements ComposerController {
  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});

  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});
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
}
