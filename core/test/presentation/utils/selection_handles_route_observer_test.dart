import 'dart:async';

import 'package:core/presentation/utils/android_selection_handles_manager.dart';
import 'package:core/presentation/utils/selection_handles_overlay_guard.dart';
import 'package:core/presentation/utils/selection_handles_route_observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AndroidSelectionHandlesManager.channelName);
  final binaryMessenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  List<String> recordNativeMethods() {
    final methods = <String>[];
    binaryMessenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return true;
    });
    return methods;
  }

  Route<dynamic> fakePageRoute() =>
      PageRouteBuilder<dynamic>(pageBuilder: (_, __, ___) => const SizedBox());

  Route<dynamic> fakeOverlayRoute() => PageRouteBuilder<dynamic>(
    opaque: false,
    pageBuilder: (_, __, ___) => const SizedBox(),
  );

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 10));

  late SelectionHandlesRouteObserver observer;
  late List<String> methods;

  void useObserverOn(TargetPlatform platform) {
    debugDefaultTargetPlatformOverride = platform;
    observer = SelectionHandlesRouteObserver();
    methods = recordNativeMethods();
  }

  tearDown(() {
    binaryMessenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('SelectionHandlesRouteObserver on Android', () {
    setUp(() => useObserverOn(TargetPlatform.android));

    test(
      'suspends native handles when a route is pushed over another',
      () async {
        observer.didPush(fakeOverlayRoute(), fakePageRoute());
        await settle();

        expect(methods, ['suspend']);
      },
    );

    test('does not suspend for the initial route', () async {
      observer.didPush(fakeOverlayRoute(), null);
      await settle();

      expect(methods, isEmpty);
    });

    test('does not suspend for full-screen page routes', () async {
      observer.didPush(fakePageRoute(), fakePageRoute());
      await settle();

      expect(methods, isEmpty);
    });

    test('restores native handles when a suspended route is popped', () async {
      final route = fakeOverlayRoute();

      observer.didPush(route, fakePageRoute());
      await settle();

      observer.didPop(route, fakePageRoute());
      await settle();

      expect(methods, ['suspend', 'restore']);
    });

    test('restores when route is popped before suspend completes', () async {
      final route = fakeOverlayRoute();
      final suspendCompleter = Completer<bool>();

      binaryMessenger.setMockMethodCallHandler(channel, (call) async {
        methods.add(call.method);
        if (call.method == AndroidSelectionHandlesManager.suspendMethod) {
          return suspendCompleter.future;
        }
        return true;
      });

      observer.didPush(route, fakePageRoute());
      observer.didPop(route, fakePageRoute());
      await settle();

      expect(methods, ['suspend']);

      suspendCompleter.complete(true);
      await settle();

      expect(methods, ['suspend', 'restore']);
    });

    test('restores native handles when a suspended route is removed', () async {
      final route = fakeOverlayRoute();

      observer.didPush(route, fakePageRoute());
      await settle();

      observer.didRemove(route, fakePageRoute());
      await settle();

      expect(methods, ['suspend', 'restore']);
    });

    test(
      'does not double-suspend routes opened inside a manual guard',
      () async {
        final route = fakeOverlayRoute();

        await SelectionHandlesOverlayGuard.protect<void>(
          action: (_) async {
            observer.didPush(route, fakePageRoute());
            await settle();

            observer.didPop(route, fakePageRoute());
            await settle();
          },
        );
        await settle();

        expect(methods, ['suspend', 'restore']);
      },
    );
  });

  group('SelectionHandlesRouteObserver on non-Android platforms', () {
    setUp(() => useObserverOn(TargetPlatform.iOS));

    test('never touches the native channel', () async {
      observer.didPush(fakeOverlayRoute(), fakePageRoute());
      observer.didPop(fakeOverlayRoute(), fakePageRoute());
      observer.didRemove(fakeOverlayRoute(), fakePageRoute());
      await settle();

      expect(methods, isEmpty);
    });
  });
}
