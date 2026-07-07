import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/android_editor_selection_handles_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    AndroidEditorSelectionHandlesManager.channelName,
  );
  final manager = AndroidEditorSelectionHandlesManager(channel: channel);

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

  group('AndroidEditorSelectionHandlesManager::suspendSelectionHandles', () {
    test('returns false when editor javascript executor is missing', () async {
      final nativeMethods = recordNativeMethods();

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: null,
      );

      expect(result, isFalse);
      expect(nativeMethods, isEmpty);
    });

    test(
      'returns false and does not call native channel when editor is inactive',
      () async {
        final nativeMethods = recordNativeMethods();

        final result = await manager.suspendSelectionHandles(
          evaluateJavascript: ({required source}) async => false,
        );

        expect(result, isFalse);
        expect(nativeMethods, isEmpty);
      },
    );

    test('calls native suspend when editor has selection or caret', () async {
      final nativeMethods = recordNativeMethods();

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) async {
          expect(
            source,
            AndroidEditorSelectionHandlesManager.storeSelectionRangeScript,
          );
          return AndroidEditorSelectionHandlesManager.trueValue;
        },
      );

      expect(result, isTrue);
      expect(nativeMethods, [
        AndroidEditorSelectionHandlesManager.suspendMethod,
      ]);
    });

    test('returns false instead of throwing when javascript fails', () async {
      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) => throw StateError('failed'),
      );

      expect(result, isFalse);
    });

    test(
      'returns false when native channel reports it did not suspend handles',
      () async {
        mockNativeResult(false);

        final result = await manager.suspendSelectionHandles(
          evaluateJavascript: ({required source}) async =>
              AndroidEditorSelectionHandlesManager.trueValue,
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

    test('returns false instead of throwing when native channel fails', () async {
      mockNativeThrows();

      final result = await manager.suspendSelectionHandles(
        evaluateJavascript: ({required source}) async => true,
      );

      expect(result, isFalse);
    });
  });

  group('AndroidEditorSelectionHandlesManager::restoreSelectionHandles', () {
    test(
      'restores native handles only when editor focus is not needed',
      () async {
        final calls = <String>[];
        binaryMessenger.setMockMethodCallHandler(channel, (call) async {
          calls.add('native:${call.method}');
          return true;
        });

        await manager.restoreSelectionHandles(
          restoreEditorFocus: false,
          evaluateJavascript: ({required source}) async {
            calls.add('js');
            return true;
          },
          focusEditor: () async => calls.add('focus'),
        );

        expect(calls, [
          'native:${AndroidEditorSelectionHandlesManager.restoreMethod}',
        ]);
      },
    );

    test('restores editor selection before and after native restore', () async {
      final calls = <String>[];
      binaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add('native:${call.method}');
        return true;
      });

      await manager.restoreSelectionHandles(
        restoreEditorFocus: true,
        evaluateJavascript: ({required source}) async {
          expect(
            source,
            AndroidEditorSelectionHandlesManager.restoreSelectionRangeScript,
          );
          calls.add('js');
          return true;
        },
        focusEditor: () async => calls.add('focus'),
      );

      expect(calls, [
        'js',
        'focus',
        'native:${AndroidEditorSelectionHandlesManager.restoreMethod}',
        'js',
        'focus',
      ]);
    });

    test(
      'still restores native handles when editor callbacks are null',
      () async {
        final nativeMethods = recordNativeMethods();

        await manager.restoreSelectionHandles(
          restoreEditorFocus: true,
          evaluateJavascript: null,
          focusEditor: null,
        );

        expect(nativeMethods, [
          AndroidEditorSelectionHandlesManager.restoreMethod,
        ]);
      },
    );

    test('does not throw when native restore fails', () async {
      mockNativeThrows();

      await expectLater(
        manager.restoreSelectionHandles(
          restoreEditorFocus: false,
          evaluateJavascript: null,
          focusEditor: null,
        ),
        completes,
      );
    });
  });

  group('AndroidEditorSelectionHandlesManager on non-Android platforms', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('suspend never touches the editor or native channel', () async {
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

    test('restore never touches the editor or native channel', () async {
      final nativeMethods = recordNativeMethods();
      var evaluatedJavascript = false;
      var focusedEditor = false;

      await manager.restoreSelectionHandles(
        restoreEditorFocus: true,
        evaluateJavascript: ({required source}) async {
          evaluatedJavascript = true;
          return true;
        },
        focusEditor: () async => focusedEditor = true,
      );

      expect(evaluatedJavascript, isFalse);
      expect(focusedEditor, isFalse);
      expect(nativeMethods, isEmpty);
    });
  });
}
