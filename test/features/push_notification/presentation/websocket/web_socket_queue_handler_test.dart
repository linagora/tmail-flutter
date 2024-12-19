
import 'package:core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

void main() {
  group('WebSocketQueueHandler::test', () {
    late WebSocketQueueHandler webSocketQueueHandler;

    setUp(() {
      webSocketQueueHandler = WebSocketQueueHandler(
        processMessageCallback: (message) async {
          log('WebSocketQueueHandler::main:message = $message');
        },
        onErrorCallback: (error, stackTrace) {
          logError('WebSocketQueueHandler::main:error = $error | stackTrace = $stackTrace');
        },
      );
    });

    tearDown(() {
      webSocketQueueHandler.dispose();
    });

    test('should process messages in queue', () async {
      final message1 = WebSocketMessage(
        newState: State('msg1'),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
      );
      final message2 = WebSocketMessage(
        newState: State('msg2'),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
      );

      webSocketQueueHandler.enqueue(message1);
      webSocketQueueHandler.enqueue(message2);

      await webSocketQueueHandler.waitForEmpty();

      expect(webSocketQueueHandler.isMessageProcessed('msg1'), isTrue);
      expect(webSocketQueueHandler.isMessageProcessed('msg2'), isTrue);
      expect(webSocketQueueHandler.queueSize, 0);
    });

    test('should not process already processed messages', () async {
      final message = WebSocketMessage(
        newState: State('msg1'),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
      );

      webSocketQueueHandler.enqueue(message);
      await webSocketQueueHandler.waitForEmpty();

      // Enqueue the same message again
      webSocketQueueHandler.enqueue(message);
      await webSocketQueueHandler.waitForEmpty();

      expect(webSocketQueueHandler.isMessageProcessed('msg1'), isTrue);
      expect(webSocketQueueHandler.queueSize, 0);
    });

    test('should remove messages up to a given message ID', () {
      final message1 = WebSocketMessage(
        newState: State('msg1'),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
      );

      final message2 = WebSocketMessage(
        newState: State('msg2'),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
      );

      final message3 = WebSocketMessage(
        newState: State('msg3'),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
      );

      webSocketQueueHandler.enqueue(message1);
      webSocketQueueHandler.enqueue(message2);
      webSocketQueueHandler.enqueue(message3);

      webSocketQueueHandler.removeMessagesUpToCurrent('msg2');

      expect(webSocketQueueHandler.queueSize, 1);
      expect(webSocketQueueHandler.isMessageProcessed('msg1'), false);
      expect(webSocketQueueHandler.isMessageProcessed('msg2'), false);
    });
  });
}
