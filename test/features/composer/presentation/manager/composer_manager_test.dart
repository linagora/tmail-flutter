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

  group('ComposerManager::arrangeComposerWhenComposerQueueChanged::', () {
    test('Should persist display all hidden composers on a large screen (2500px)', () {
      const screenWidth = 2500.0; // Total width for 3 normal composers: 1978px < 2500px

      screenDisplayMode1.value = ScreenDisplayMode.hidden;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should keep all normal composers unchanged on a medium screen that fits perfectly (1978px)', () {
      const screenWidth = 1978.0; // Exactly fits 3 normal composers: 3 * 600 + 130 + 16*2 + 8*2

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should minimize and hide composers on a small screen when total width exceeds available space (1000px)', () {
      const screenWidth = 1000.0; // Less than space needed for 3 normal composers (1800px)

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should adjust composers on a tablet screen when one is hidden and space is sufficient (1500px)', () {
      const screenWidth = 1500.0; // Fits 2 normal composers: 1370px < 1500px

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should handle mixed states on a very small screen by minimizing and hiding composers (600px)', () {
      const screenWidth = 600.0; // Less than space for 1 normal + 1 minimized (1000px)

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.minimize);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should persist display all hidden composers on an extra large screen (4000px)', () {
      const screenWidth = 4000.0; // Plenty of space for 3 normal composers (1978px < 4000px)

      screenDisplayMode1.value = ScreenDisplayMode.hidden;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should hide all composers on a very narrow screen when space is extremely limited (200px)', () {
      const screenWidth = 200.0; // Less than space for even 1 minimized composer (400px)

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });
  });

  group('ComposerManager::arrangeComposerWhenComposerDisplayModeChanged::', () {
    test('Should do nothing when the composer queue is empty', () {
      composerManager.composerIdsQueue.clear();
      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: 1000.0,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should refresh without changing states when new display mode is hidden (1000px)', () {
      const screenWidth = 1000.0;

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.normal;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.hidden,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.normal);
    });

    test('Should persist show other hidden composers on a large screen when one changes to normal (2500px)', () {
      const screenWidth = 2500.0; // Plenty of space for 3 normal composers

      screenDisplayMode1.value = ScreenDisplayMode.hidden;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should hide one minimized composer on a small screen when one changes to normal (1000px)', () {
      const screenWidth = 1000.0; // Not enough for 2 normal composers

      screenDisplayMode1.value = ScreenDisplayMode.minimize;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.minimize;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.minimize); // Not changed directly
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.minimize);
    });

    test('Should minimize one normal composer on a medium screen when one changes to minimize (1500px)', () {
      const screenWidth = 1500.0; // Fits 2 normal composers (1370px < 1500px)

      screenDisplayMode1.value = ScreenDisplayMode.normal;
      screenDisplayMode2.value = ScreenDisplayMode.normal;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '2',
        newDisplayMode: ScreenDisplayMode.minimize,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode2.value, ScreenDisplayMode.normal);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should hide one minimized composer on a very small screen when one changes to normal (600px)', () {
      const screenWidth = 600.0; // Less than space for 1 normal + 1 minimized

      screenDisplayMode1.value = ScreenDisplayMode.minimize;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.minimize); // Not changed directly
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should show other hidden composers as minimized on an extra large screen when one changes to minimize (4000px)', () {
      const screenWidth = 4000.0; // Plenty of space for 3 normal composers

      screenDisplayMode1.value = ScreenDisplayMode.hidden;
      screenDisplayMode2.value = ScreenDisplayMode.hidden;
      screenDisplayMode3.value = ScreenDisplayMode.hidden;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.minimize,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });

    test('Should hide other minimized composers on a very narrow screen when one changes to normal (200px)', () {
      const screenWidth = 200.0; // Less than space for 1 minimized composer

      screenDisplayMode1.value = ScreenDisplayMode.minimize;
      screenDisplayMode2.value = ScreenDisplayMode.minimize;
      screenDisplayMode3.value = ScreenDisplayMode.minimize;

      composerManager.arrangeComposerWhenComposerDisplayModeChanged(
        screenWidth: screenWidth,
        updatedComposerId: '1',
        newDisplayMode: ScreenDisplayMode.normal,
      );

      expect(screenDisplayMode1.value, ScreenDisplayMode.minimize); // Not changed directly
      expect(screenDisplayMode2.value, ScreenDisplayMode.hidden);
      expect(screenDisplayMode3.value, ScreenDisplayMode.hidden);
    });
  });
}