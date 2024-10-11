import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/web_socket_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/web_socket_push_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/connect_web_socket_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'connect_web_socket_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WebSocketRepository>()])
void main() {
  late MockWebSocketRepository webSocketRepository;
  late ConnectWebSocketInteractor connectWebSocketInteractor;

  setUp(() {
    webSocketRepository = MockWebSocketRepository();
    connectWebSocketInteractor = ConnectWebSocketInteractor(webSocketRepository);
  });

  group('connect web socket interactor test:', () {
    test(
      'should yield WebSocketPushStateReceived with StateChange '
      'when web socket repository yield StateChange',
    () {
      // arrange
      final stateChangeJson = {
        "@type": "StateChange",
        "changed": <String, dynamic>{}
      };
      when(webSocketRepository.getWebSocketChannel(any, any))
        .thenAnswer((_) => Stream.value(stateChangeJson));
      
      // assert
      expect(
        connectWebSocketInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId),
        emitsInOrder([
          Right(InitializingWebSocketPushChannel()),
          Right(WebSocketPushStateReceived(StateChange.fromJson(stateChangeJson))),
      ]));
    });

    test(
      'should yield WebSocketPushStateReceived with null '
      'when web socket repository yield WebSocketEcho',
    () {
      // arrange
      final webSocketEchoJson = {
        "@type": "Response",
        "requestId": "R1",
        "methodResponses": [["Core/echo", {}, "c0"]]
      };
      when(webSocketRepository.getWebSocketChannel(any, any))
        .thenAnswer((_) => Stream.value(webSocketEchoJson));
      
      // assert
      expect(
        connectWebSocketInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId),
        emitsInOrder([
          Right(InitializingWebSocketPushChannel()),
          Right(WebSocketPushStateReceived(null)),
      ]));
    });

    test(
      'should yield WebSocketConnectionFailed '
      'when web socket repository throws exception',
    () {
      // arrange
      final exception = Exception();
      when(webSocketRepository.getWebSocketChannel(any, any))
        .thenThrow(exception);
      
      // assert
      expect(
        connectWebSocketInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId),
        emitsInOrder([
          Right(InitializingWebSocketPushChannel()),
          Left(WebSocketConnectionFailed(exception: exception)),
      ]));
    });

    test(
      'should yield WebSocketConnectionFailed '
      'when web socket repository yield data '
      'and data is not web socket echo',
    () async {
      // arrange
      final notWebSocketEchoJson = {
        "@type": "Response",
        "requestId": "R1",
        "methodResponses": [["Core/not-echo", {}, "c0"]]
      };
      when(webSocketRepository.getWebSocketChannel(any, any))
        .thenAnswer((_) => Stream.value(notWebSocketEchoJson));

      // act
      final lastState = await connectWebSocketInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId).last;
      
      // assert
      expect(
        lastState.fold(
          (failure) => failure is WebSocketConnectionFailed,
          (success) => false,
        ),
        true
      );
    });
  });
}