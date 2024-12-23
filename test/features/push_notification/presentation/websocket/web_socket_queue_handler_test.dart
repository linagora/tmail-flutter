import 'dart:async';
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
      late List<String> processedMessages;

      setUp(() {
        processedMessages = [];
      });

      tearDown(() {
        handler.dispose();
      });

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

      test('Duplicate messages should be skipped', () async {
        final message = MockWebSocketMessage('duplicate_msg');

        handler.enqueue(message);
        await handler.waitForEmpty();

        handler.enqueue(message);
        await handler.waitForEmpty();

        expect(processedMessages.length, equals(1));
        expect(processedMessages, equals(['duplicate_msg']));
      });

      test('Queue size should not exceed maximum size', () async {
        // Enqueue more messages than the max queue size
        final messages = List.generate(130, (i) => MockWebSocketMessage('msg_$i'));

        for (var message in messages) {
          handler.enqueue(message);
        }

        expect(handler.queueSize, lessThanOrEqualTo(128));
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

    group('Queue Size Management Tests', () {
      test('Queue should drop oldest message when full', () async {
        late List<dynamic> errors = [];

        final handler = WebSocketQueueHandler(
          processMessageCallback: (message) async {
            await Future.delayed(const Duration(milliseconds: 10)); // Simulate processing time
            processedMessages.add(message.id);
          },
          onErrorCallback: (error, stackTrace) {
            errors.add(error);
          },
        );

        // Fill the queue to maximum capacity (128)
        for (var i = 0; i < 128; i++) {
          handler.enqueue(MockWebSocketMessage('msg_$i'));
        }

        expect(handler.queueSize, equals(128));

        // Add one more message
        handler.enqueue(MockWebSocketMessage('msg_128'));

        // Queue size should still be 128
        expect(handler.queueSize, equals(128));

        // Process all messages
        await handler.waitForEmpty();

        // Verify that msg_0 (the oldest) was dropped and msg_128 (newest) was processed
        expect(processedMessages.contains('msg_0'), isFalse);
        expect(processedMessages.contains('msg_1'), isTrue);
        expect(processedMessages.contains('msg_127'), isTrue);
        expect(processedMessages.contains('msg_128'), isTrue);
      });

      test('Queue should maintain size limit during message removal', () async {
        final processedIds = <String>[];
        late List<dynamic> errors = [];

        final handler = WebSocketQueueHandler(
          processMessageCallback: (message) async {
            await Future.delayed(const Duration(milliseconds: 10));
            processedIds.add(message.id);
          },
          onErrorCallback: (error, stackTrace) {
            errors.add(error);
          },
        );

        // Fill queue to capacity
        for (var i = 0; i < 128; i++) {
          handler.enqueue(MockWebSocketMessage('msg_$i'));
        }

        // Remove messages up to msg_64
        handler.removeMessagesUpToCurrent('msg_64');

        // Add new messages to fill the queue again
        for (var i = 128; i < 192; i++) {
          handler.enqueue(MockWebSocketMessage('msg_$i'));
        }

        expect(handler.queueSize, lessThanOrEqualTo(128),
            reason: 'Queue size should not exceed maximum after removal and refill');

        await handler.waitForEmpty();

        // Verify that earlier messages were properly removed
        for (var i = 0; i <= 64; i++) {
          expect(processedMessages.contains('msg_$i'), isFalse,
              reason: 'Message msg_$i should have been removed');
        }
      });
    });

    group('Concurrent Operations', () {
      late WebSocketQueueHandler handler;
      late List<dynamic> errors;

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

      test('Should handle concurrent enqueueing while processing is blocked', () async {
        final processingCompleter = Completer<void>();
        final processedIds = <String>[];
        errors = [];
        var processingStarted = Completer<void>();

        // Create handler with a processing delay to simulate long-running task
        handler = WebSocketQueueHandler(
          processMessageCallback: (message) async {
            if (!processingStarted.isCompleted) {
              processingStarted.complete();
            }
            await processingCompleter.future; // Block processing
            processedIds.add(message.id);
          },
          onErrorCallback: (error, stackTrace) {
            errors.add(error);
          },
        );

        // Enqueue first message to start processing
        handler.enqueue(MockWebSocketMessage('initial_msg'));

        // Wait for processing to start
        await processingStarted.future;

        // Concurrently enqueue messages while first message is still processing
        await Future.wait(
            List.generate(150, (i) => Future(() {
              handler.enqueue(MockWebSocketMessage('concurrent_$i'));
            }))
        );

        // Verify queue size is capped at max while processing is blocked
        expect(handler.queueSize, lessThanOrEqualTo(128));

        // Allow processing to continue
        processingCompleter.complete();

        await handler.waitForEmpty();
        // Verify process order and dropped messages
        expect(processedIds[0], equals('initial_msg'));
        expect(processedIds.length, lessThanOrEqualTo(129));
        expect(handler.isMessageProcessed('concurrent_149'), isTrue);
      });

      test('Should handle rapid enqueueing during active processing', () async {
        final processedIds = <String>[];
        final processingStarted = Completer<void>();
        final batchProcessing = Completer<void>();
        errors = [];

        // Create handler with controlled processing delays
        handler = WebSocketQueueHandler(
          processMessageCallback: (message) async {
            if (!processingStarted.isCompleted) {
              processingStarted.complete();
              await batchProcessing.future;
            }
            processedIds.add(message.id);
          },
          onErrorCallback: (error, stackTrace) {
            errors.add(error);
          },
        );

        // Start with initial batch
        for (var i = 0; i < 50; i++) {
          handler.enqueue(MockWebSocketMessage('batch1_$i'));
        }

        // Wait for the first message to start processing
        await processingStarted.future;

        // Add second batch while first batch is blocked
        for (var i = 0; i < 50; i++) {
          handler.enqueue(MockWebSocketMessage('batch2_$i'));
        }

        // Add third batch immediately
        for (var i = 0; i < 50; i++) {
          handler.enqueue(MockWebSocketMessage('batch3_$i'));
        }

        // Allow processing to continue
        batchProcessing.complete();

        // Wait for queue to be empty
        await handler.waitForEmpty();

        // Verify results
        expect(processedIds.length, lessThanOrEqualTo(129),
            reason: 'Total processed messages should not exceed queue capacity');

        // Check if we have messages from the latest batch
        final lastBatchCount = processedIds
            .where((id) => id.startsWith('batch3_'))
            .length;
        expect(lastBatchCount, greaterThan(0),
            reason: 'Should have processed some messages from the latest batch');

        // Verify that some early messages were dropped
        final firstBatchCount = processedIds
            .where((id) => id.startsWith('batch1_'))
            .length;
        expect(firstBatchCount, lessThan(50),
            reason: 'Some messages from first batch should have been dropped');
      });

      test('Should handle concurrent removeMessagesUpToCurrent during processing', () async {
        final processedIds = <String>[];
        final processingDelay = Completer<void>();
        errors = [];

        handler = WebSocketQueueHandler(
          processMessageCallback: (message) async {
            await processingDelay.future;
            processedIds.add(message.id);
          },
          onErrorCallback: (error, stackTrace) {
            errors.add(error);
          },
        );

        // Fill queue
        for (var i = 0; i < 128; i++) {
          handler.enqueue(MockWebSocketMessage('msg_$i'));
        }

        // Start concurrent operations
        final futures = <Future>[];

        // Add new messages
        futures.add(Future(() async {
          for (var i = 128; i < 256; i++) {
            handler.enqueue(MockWebSocketMessage('msg_$i'));
            await Future.delayed(const Duration(microseconds: 100));
          }
        }));

        // Concurrently remove messages
        futures.add(Future(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          handler.removeMessagesUpToCurrent('msg_64');
        }));

        // Allow processing to continue after concurrent operations
        await Future.delayed(const Duration(milliseconds: 50));
        processingDelay.complete();

        await Future.wait(futures);
        await handler.waitForEmpty();

        expect(processedIds.length, lessThanOrEqualTo(192));

        // Verify that messages after removal point were processed
        for (var id in processedIds.skip(1)) {
          final messageNumber = int.parse(id.split('_')[1]);
          expect(messageNumber, greaterThan(64),
              reason: 'Only messages after msg_64 should be processed');
        }
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
        expect(handler.queueSize, equals(0));
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
