import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const messagesChannel = MethodChannel('receive_sharing_intent/messages');
  const mediaEventChannel = EventChannel('receive_sharing_intent/events-media');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<void> emitSharedMediaEvent(List<Map<String, dynamic>> mediaList) async {
    final envelope =
        const StandardMethodCodec().encodeSuccessEnvelope(jsonEncode(mediaList));
    await messenger.handlePlatformMessage(mediaEventChannel.name, envelope, (_) {});
  }

  setUp(() {
    messenger.setMockMethodCallHandler(messagesChannel, (call) async => null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(messagesChannel, null);
  });

  group('EmailReceiveManager', () {
    test(
      'registerReceivingFileSharingStreamWhileAppClosed buffers a share that '
      'arrives on the live EventChannel before anyone subscribes to '
      'pendingSharedFileInfo',
      () async {
        final manager = EmailReceiveManager();

        manager.registerReceivingFileSharingStreamWhileAppClosed();
        // Let getInitialMedia's mocked round trip (empty result) settle first,
        // so it can't race with and clobber the event emitted below.
        await Future<void>.delayed(Duration.zero);

        await emitSharedMediaEvent([
          {'path': 'mailto:test@example.com', 'type': 'url'},
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(manager.pendingSharedFileInfo.value, hasLength(1));
        expect(
          manager.pendingSharedFileInfo.value.first.path,
          'mailto:test@example.com',
        );
      },
    );

    test(
      'pendingSharedFileInfo replays the buffered share to a subscriber that '
      'attaches after the event already arrived',
      () async {
        final manager = EmailReceiveManager();

        manager.registerReceivingFileSharingStreamWhileAppClosed();
        await Future<void>.delayed(Duration.zero);

        await emitSharedMediaEvent([
          {'path': 'mailto:late@example.com', 'type': 'url'},
        ]);
        await Future<void>.delayed(Duration.zero);

        final received = await manager.pendingSharedFileInfo.first;

        expect(received, hasLength(1));
        expect(received.first.path, 'mailto:late@example.com');
      },
    );

    test(
      'an empty getInitialMedia result that resolves after a live share arrives '
      'must not clobber that share',
      () async {
        // Hold getInitialMedia (and reset) pending until we release the gate,
        // so the live share below is guaranteed to arrive first — reproducing a
        // warm-app share landing while startup is still settling.
        final initialMediaGate = Completer<void>();
        messenger.setMockMethodCallHandler(messagesChannel, (call) async {
          await initialMediaGate.future;
          return null; // getInitialMedia -> empty list
        });

        final manager = EmailReceiveManager();
        manager.registerReceivingFileSharingStreamWhileAppClosed();

        await emitSharedMediaEvent([
          {'path': 'mailto:warm@example.com', 'type': 'url'},
        ]);
        await Future<void>.delayed(Duration.zero);

        // Now let the empty cold-start result resolve; the guard must keep it
        // from overwriting the already-buffered live share.
        initialMediaGate.complete();
        await Future<void>.delayed(Duration.zero);

        expect(manager.pendingSharedFileInfo.value, hasLength(1));
        expect(
          manager.pendingSharedFileInfo.value.first.path,
          'mailto:warm@example.com',
        );
      },
    );
  });
}
