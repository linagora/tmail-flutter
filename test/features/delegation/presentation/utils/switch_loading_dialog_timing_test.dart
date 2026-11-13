import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/switch_loading_dialog_timing.dart';

void main() {
  late List<bool> visibility;
  late SwitchLoadingDialogTiming timing;

  setUp(() {
    visibility = [];
    timing = SwitchLoadingDialogTiming(onVisibilityChanged: visibility.add);
  });

  tearDown(() => timing.dispose());

  test('does not show when the switch ends before the show delay', () {
    fakeAsync((async) {
      timing.switchStarted();
      async.elapse(const Duration(milliseconds: 299));
      timing.switchEnded();
      async.elapse(SwitchLoadingDialogTiming.showDelay);

      expect(visibility, isEmpty);
      expect(timing.isVisible, isFalse);
    });
  });

  test('shows after the show delay while the switch still runs', () {
    fakeAsync((async) {
      timing.switchStarted();
      async.elapse(SwitchLoadingDialogTiming.showDelay);

      expect(visibility, [true]);
      expect(timing.isVisible, isTrue);
    });
  });

  test('stays visible for the minimum time after the switch ends', () {
    fakeAsync((async) {
      timing.switchStarted();
      async.elapse(SwitchLoadingDialogTiming.showDelay);
      timing.switchEnded();
      async.elapse(const Duration(milliseconds: 499));

      expect(visibility, [true]);
      expect(timing.isVisible, isTrue);

      async.elapse(const Duration(milliseconds: 1));

      expect(visibility, [true, false]);
      expect(timing.isVisible, isFalse);
    });
  });

  test('hides at once when the switch already lasted the minimum time', () {
    fakeAsync((async) {
      timing.switchStarted();
      async.elapse(SwitchLoadingDialogTiming.showDelay);
      async.elapse(SwitchLoadingDialogTiming.minVisible);
      timing.switchEnded();
      async.flushMicrotasks();

      expect(visibility, [true, false]);
    });
  });

  test('keeps the dialog shown when a new switch starts during the minimum time', () {
    fakeAsync((async) {
      timing.switchStarted();
      async.elapse(SwitchLoadingDialogTiming.showDelay);
      timing.switchEnded();
      async.elapse(const Duration(milliseconds: 100));
      timing.switchStarted();
      async.elapse(const Duration(milliseconds: 400));

      expect(visibility, [true]);
      expect(timing.isVisible, isTrue);

      timing.switchEnded();
      async.flushMicrotasks();

      expect(visibility, [true, false]);
    });
  });

  test('does not show while idle', () {
    fakeAsync((async) {
      async.elapse(const Duration(seconds: 1));

      expect(visibility, isEmpty);
      expect(timing.isVisible, isFalse);
    });
  });

  test('zero show delay still paints when the switch ends in microtasks', () {
    fakeAsync((async) {
      timing = SwitchLoadingDialogTiming(
        onVisibilityChanged: visibility.add,
        showDelay: Duration.zero,
      );

      timing.switchStarted();
      // Microtask-fast load finishes before the zero-delay show runs.
      timing.switchEnded();
      expect(visibility, isEmpty);

      async.flushMicrotasks();
      expect(visibility, [true]);
      expect(timing.isVisible, isTrue);

      async.elapse(SwitchLoadingDialogTiming.minVisible);
      expect(visibility, [true, false]);
    });
  });
}
