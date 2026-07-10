import 'package:core/presentation/utils/selection_handles_overlay_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'com.linagora.android.tmail/android_selection_handles',
  );
  final binaryMessenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  List<String> recordNativeMethods({bool suspendResult = true}) {
    final methods = <String>[];
    binaryMessenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return suspendResult;
    });
    return methods;
  }

  tearDown(() {
    binaryMessenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('SelectionHandlesOverlayGuard on non-Android platforms', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    test(
      'runs the action with suspended=false and never touches the native channel',
      () async {
        final nativeMethods = recordNativeMethods();
        bool? suspendedSeen;

        final result = await SelectionHandlesOverlayGuard.protect<String>(
          action: (suspended) async {
            suspendedSeen = suspended;
            return 'ran';
          },
        );

        expect(suspendedSeen, isFalse);
        expect(result, 'ran');
        expect(nativeMethods, isEmpty);
      },
    );

    test('never evaluates javascript nor restores owner focus', () async {
      var evaluatedJavascript = false;
      var focusedOwner = false;

      await SelectionHandlesOverlayGuard.protect<void>(
        evaluateJavascript: ({required source}) async {
          evaluatedJavascript = true;
          return true;
        },
        focusSelectionOwner: () async => focusedOwner = true,
        restoreSelectionOwnerFocus: (_) => true,
        action: (_) async {},
      );

      expect(evaluatedJavascript, isFalse);
      expect(focusedOwner, isFalse);
    });

    test('propagates errors thrown by the action', () async {
      await expectLater(
        SelectionHandlesOverlayGuard.protect<void>(
          action: (_) async => throw StateError('boom'),
        ),
        throwsStateError,
      );
    });
  });

  group('SelectionHandlesOverlayGuard on Android', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    Future<bool?> protectAndReturnSuspendedFlag() async {
      bool? suspendedSeen;
      await SelectionHandlesOverlayGuard.protect<void>(
        action: (suspended) async {
          suspendedSeen = suspended;
        },
      );
      return suspendedSeen;
    }

    test('suspends and restores native handles around the action', () async {
      final nativeMethods = recordNativeMethods();

      final suspendedSeen = await protectAndReturnSuspendedFlag();

      expect(suspendedSeen, isTrue);
      expect(nativeMethods, ['suspend', 'restore']);
    });

    test(
      'runs the action unguarded when native suspend does not happen',
      () async {
        final nativeMethods = recordNativeMethods(suspendResult: false);

        final suspendedSeen = await protectAndReturnSuspendedFlag();

        expect(suspendedSeen, isFalse);
        expect(nativeMethods, ['suspend']);
      },
    );
  });
}
