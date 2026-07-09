import 'package:core/presentation/utils/android_selection_handles_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AndroidSelectionHandlesManager.channelName);
  final manager = AndroidSelectionHandlesManager(channel: channel);

  final binaryMessenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Records every native method invoked on [channel] into the returned list.
  List<String> recordNativeMethods() {
    final methods = <String>[];
    binaryMessenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return true;
    });
    return methods;
  }

  void mockNativeResult(dynamic result) {
    binaryMessenger.setMockMethodCallHandler(channel, (call) async => result);
  }

  void mockNativeThrows() {
    binaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'error'),
    );
  }

  tearDown(() {
    binaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('AndroidSelectionHandlesManager::suspendSelectionHandles', () {
    test(
      'suspends native handles directly when no javascript executor is given',
      () async {
        final nativeMethods = recordNativeMethods();

        final result = await manager.suspendSelectionHandles(
          evaluateJavascript: null,
        );

        expect(result, isTrue);
        expect(nativeMethods, [AndroidSelectionHandlesManager.suspendMethod]);
      },
    );

    test(
      'returns false and does not call native channel when owner is inactive',
      () async {
        final nativeMethods = recordNativeMethods();

        final result = await manager.suspendSelectionHandles(
          evaluateJavascript: ({required source}) async => false,
        );

        expect(result, isFalse);
        expect(nativeMethods, isEmpty);
      },
    );

    test('calls native suspend when owner has selection or caret', () async {
      final nativeMethods = recordNativeMethods();

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) async {
          expect(
            source,
            AndroidSelectionHandlesManager.storeSelectionRangeScript,
          );
          return AndroidSelectionHandlesManager.trueValue;
        },
      );

      expect(result, isTrue);
      expect(nativeMethods, [AndroidSelectionHandlesManager.suspendMethod]);
    });

    test('returns false instead of throwing when javascript fails', () async {
      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) => throw StateError('failed'),
      );

      expect(result, isFalse);
    });

    test('returns false when native-only suspend is not applied', () async {
      mockNativeResult(false);

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: null,
      );

      expect(result, isFalse);
    });

    test(
      'returns false when native channel reports it did not suspend handles',
      () async {
        mockNativeResult(false);

        final result = await manager.suspendSelectionHandles(
          evaluateJavascript: ({required source}) async =>
              AndroidSelectionHandlesManager.trueValue,
        );

        expect(result, isFalse);
      },
    );

    test('returns false when native channel returns null', () async {
      mockNativeResult(null);

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) async => true,
      );

      expect(result, isFalse);
    });

    test(
      'returns false instead of throwing when native channel fails',
      () async {
        mockNativeThrows();

        final result = await manager.suspendSelectionHandles(
          evaluateJavascript: ({required source}) async => true,
        );

        expect(result, isFalse);
      },
    );
  });

  group('AndroidSelectionHandlesManager::restoreSelectionHandles', () {
    test(
      'restores native handles only when owner focus is not needed',
      () async {
        final calls = <String>[];
        binaryMessenger.setMockMethodCallHandler(channel, (call) async {
          calls.add('native:${call.method}');
          return true;
        });

        await manager.restoreSelectionHandles(
          restoreSelectionOwnerFocus: false,
          evaluateJavascript: ({required source}) async {
            calls.add('js');
            return true;
          },
          focusSelectionOwner: () async => calls.add('focus'),
        );

        expect(calls, [
          'native:${AndroidSelectionHandlesManager.restoreMethod}',
        ]);
      },
    );

    test('restores owner selection before and after native restore', () async {
      final calls = <String>[];
      binaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add('native:${call.method}');
        return true;
      });

      await manager.restoreSelectionHandles(
        restoreSelectionOwnerFocus: true,
        evaluateJavascript: ({required source}) async {
          expect(
            source,
            AndroidSelectionHandlesManager.restoreSelectionRangeScript,
          );
          calls.add('js');
          return true;
        },
        focusSelectionOwner: () async => calls.add('focus'),
      );

      expect(calls, [
        'js',
        'focus',
        'native:${AndroidSelectionHandlesManager.restoreMethod}',
        'js',
        'focus',
      ]);
    });

    test(
      'still restores native handles when owner callbacks are null',
      () async {
        final nativeMethods = recordNativeMethods();

        await manager.restoreSelectionHandles(
          restoreSelectionOwnerFocus: true,
          evaluateJavascript: null,
          focusSelectionOwner: null,
        );

        expect(nativeMethods, [AndroidSelectionHandlesManager.restoreMethod]);
      },
    );

    test('does not throw when native restore fails', () async {
      mockNativeThrows();

      await expectLater(
        manager.restoreSelectionHandles(
          restoreSelectionOwnerFocus: false,
          evaluateJavascript: null,
          focusSelectionOwner: null,
        ),
        completes,
      );
    });
  });

  group('AndroidSelectionHandlesManager on non-Android platforms', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('suspend never touches the owner or native channel', () async {
      final nativeMethods = recordNativeMethods();
      var evaluatedJavascript = false;

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) async {
          evaluatedJavascript = true;
          return true;
        },
      );

      expect(result, isFalse);
      expect(evaluatedJavascript, isFalse);
      expect(nativeMethods, isEmpty);
    });

    test('restore never touches the owner or native channel', () async {
      final nativeMethods = recordNativeMethods();
      var evaluatedJavascript = false;
      var focusedOwner = false;

      await manager.restoreSelectionHandles(
        restoreSelectionOwnerFocus: true,
        evaluateJavascript: ({required source}) async {
          evaluatedJavascript = true;
          return true;
        },
        focusSelectionOwner: () async => focusedOwner = true,
      );

      expect(evaluatedJavascript, isFalse);
      expect(focusedOwner, isFalse);
      expect(nativeMethods, isEmpty);
    });
  });
}
