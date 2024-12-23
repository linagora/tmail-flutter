import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';

class MockWebSocketMessage extends WebSocketMessage {
  MockWebSocketMessage(String message)
      : super(
          newState: State(message),
        );
}

void main() {
  group('WebSocketQueueHandler::test', () {
    late Queue<String> processedMessages;

    setUp(() {
      processedMessages = Queue<String>();
    });

    WebSocketQueueHandler createHandler({
      required ProcessMessageCallback processMessageCallback,
      OnErrorCallback? onErrorCallback,
    }) {
      return WebSocketQueueHandler(
        processMessageCallback: processMessageCallback,
        onErrorCallback: onErrorCallback,
      );
    }

    group('Basic Operations', () {
      late WebSocketQueueHandler handler;

      setUp(() {
        handler = createHandler(
          processMessageCallback: (message) async {
            processedMessages.add(message.id);
          },
        );
      });

      tearDown(() => handler.dispose());

      test('Should process messages in correct order', () async {
        final messages = List.generate(5, (index) => MockWebSocketMessage('$index'));

        for (var message in messages) {
          handler.enqueue(message);
        }

        await handler.waitForEmpty();

        expect(processedMessages, containsAllInOrder(['0', '1', '2', '3', '4']));
      });

      test('Should correctly remove messages up to specified ID', () async {
        final messages = List.generate(5, (index) => MockWebSocketMessage('$index'));

        for (var message in messages) {
          handler.enqueue(message);
        }

        handler.removeMessagesUpToCurrent('2');

        expect(handler.queueSize, 2);

        await handler.waitForEmpty();

        expect(processedMessages.length, 2);
        expect(processedMessages.first, '3');
      });
    });

    group('Concurrent Operations', () {
      late WebSocketQueueHandler handler;

      setUp(() {
        handler = createHandler(
          processMessageCallback: (message) async {
            processedMessages.add(message.id);
          },
        );
      });

      tearDown(() => handler.dispose());

      test('Should handle concurrent message enqueueing', () async {
        final messages = List.generate(5, (index) => MockWebSocketMessage('$index'));

        await Future.wait(messages.map((message) => Future(() => handler.enqueue(message))));

        await handler.waitForEmpty();

        expect(processedMessages, containsAllInOrder(['0', '1', '2', '3', '4']));
      });

      test('Should maintain order under high concurrency', () async {
        final messages = List.generate(10, (index) => MockWebSocketMessage('$index'));

        for (var message in messages) {
          handler.enqueue(message);
        }

        await handler.waitForEmpty();

        expect(processedMessages, containsAllInOrder(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']));
      });
    });

    group('Error Handling', () {
      test('Should continue processing after message failure', () async {
        final handler = createHandler(
          processMessageCallback: (message) async {
            if (message.id == '2') throw Exception('Simulated Failure');
            processedMessages.add(message.id);
          },
        );

        handler.enqueue(MockWebSocketMessage('1'));
        handler.enqueue(MockWebSocketMessage('2'));
        handler.enqueue(MockWebSocketMessage('3'));

        await handler.waitForEmpty();

        expect(processedMessages, ['1', '3']);
        handler.dispose();
      });

      test('Should handle exception in process callback', () async {
        final handler = createHandler(
          processMessageCallback: (message) async {
            if (message.id == '1') throw Exception('Simulated Failure');
            processedMessages.add(message.id);
          },
          onErrorCallback: (error, stackTrace) {
            expect(error, isA<Exception>());
          },
        );

        handler.enqueue(MockWebSocketMessage('1'));
        handler.enqueue(MockWebSocketMessage('2'));

        await handler.waitForEmpty();

        expect(processedMessages, ['2']);
        handler.dispose();
      });
    });

    group('Stress Testing', () {
      late WebSocketQueueHandler handler;

      setUp(() {
        handler = createHandler(
          processMessageCallback: (message) async {
            processedMessages.add(message.id);
          },
        );
      });

      tearDown(() => handler.dispose());

      test('Should handle large bursts of messages', () async {
        handler = createHandler(
          processMessageCallback: (message) async {
            processedMessages.add(message.id);
          },
        );

        const int burstSize = 1000;
        for (int i = 0; i < burstSize; i++) {
          await Future.delayed(const Duration(milliseconds: 10));
          handler.enqueue(MockWebSocketMessage('$i'));
        }

        await handler.waitForEmpty();

        expect(processedMessages.length, burstSize);
        expect(processedMessages, List.generate(burstSize, (i) => '$i'));
      });

      test('Should handle interleaved slow and fast messages', () async {
        handler.enqueue(MockWebSocketMessage('1'));

        Future.delayed(const Duration(milliseconds: 10), () {
          handler.enqueue(MockWebSocketMessage('2'));
        });

        await handler.waitForEmpty();

        expect(processedMessages, ['1', '2']);
      });
    });
  });
}
