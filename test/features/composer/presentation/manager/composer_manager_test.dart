import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

import 'composer_manager_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<ComposerController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  late ComposerManager composerManager;
  late MockComposerController mockController1;
  late MockComposerController mockController2;
  late MockComposerController mockController3;

  late Rx<ScreenDisplayMode> screenDisplayMode1;
  late Rx<ScreenDisplayMode> screenDisplayMode2;
  late Rx<ScreenDisplayMode> screenDisplayMode3;

  setUp(() {
    Get.testMode = true;

    Get.lazyPut<ResponsiveUtils>(() => ResponsiveUtils());

    composerManager = ComposerManager();
    mockController1 = MockComposerController();
    mockController2 = MockComposerController();
    mockController3 = MockComposerController();

    // Initialize Rx variables
    screenDisplayMode1 = ScreenDisplayMode.normal.obs;
    screenDisplayMode2 = ScreenDisplayMode.normal.obs;
    screenDisplayMode3 = ScreenDisplayMode.normal.obs;

    // Mock screenDisplayMode getter
    when(mockController1.screenDisplayMode).thenReturn(screenDisplayMode1);
    when(mockController2.screenDisplayMode).thenReturn(screenDisplayMode2);
    when(mockController3.screenDisplayMode).thenReturn(screenDisplayMode3);

    Get.lazyPut<ComposerController>(() => mockController1, tag: '1');
    Get.lazyPut<ComposerController>(() => mockController2, tag: '2');
    Get.lazyPut<ComposerController>(() => mockController3, tag: '3');

    composerManager.composers['1'] = const ComposerView(key: Key('1'), composerId: '1');
    composerManager.composers['2'] = const ComposerView(key: Key('2'), composerId: '2');
    composerManager.composers['3'] = const ComposerView(key: Key('3'), composerId: '3');

    composerManager.composerIdsQueue.addAll(['1', '2', '3']);
  });

  tearDown(() {
    Get.reset();
  });

  // Only test for desktop with minWidth = 1200
  group('ComposerManager::arrangeComposerWhenComposerQueueChanged::', () {
    test('Should keep all hidden composers unchanged when screen width changes', () {
      const screenWidth = 2500.0;

      screenDisplayMode1.value = ScreenDisplayMode.hidden;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should rearrange composers when the screen width (1200px) is insufficient for all to remain normal', () {
      const screenWidth = 1200.0;

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.minimize);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should keep all composers in normal mode when the screen width (1978px) is sufficient', () {
      const screenWidth = 1978.0;

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should adjust composers when the screen width (1200px) is insufficient for all to remain minimized', () {
      const screenWidth = 1200.0;

      screenDisplayMode1.value = ScreenDisplayMode.minimize;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.minimize;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.minimize);
      expect(screenDisplayMode3.value, ScreenDisplayMode.minimize);
    });

    test('Should keep hidden composers unchanged and retain minimized composer when screen width is 1200px', () {
      const screenWidth = 1200.0;

      screenDisplayMode1.value = ScreenDisplayMode.hidden;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.minimize);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });
  });

  // Only test for desktop with minWidth = 1200
  group('ComposerManager::arrangeComposerWhenComposerDisplayModeChanged::', () {
    test('Should do nothing if the composer queue is empty', () {
      composerManager.composerIdsQueue.clear();
      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: 1200.0,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should keep hidden composers unchanged when setting one composer to normal on a large screen (2500px)', () {
      const screenWidth = 2500.0;

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should retain layout when a minimized composer remains minimized on a medium screen (1500px)', () {
      const screenWidth = 1500.0;

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '2',
        newDisplayMode: ScreenDisplayMode.minimize,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.minimize);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should keep all composers in normal mode when screen width (1978px) is sufficient', () {
      const screenWidth = 1978.0;

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '2',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should maintain hidden composers when one is minimized on an extra-large screen (4000px)', () {
      const screenWidth = 4000.0;

      screenDisplayMode1.value = ScreenDisplayMode.minimize;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.minimize,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.minimize);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });
  });
}