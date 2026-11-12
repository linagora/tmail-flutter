import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/web_socket_push_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/connect_web_socket_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/web_socket_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../fixtures/session_fixtures.dart';
import 'push_base_controller_test.mocks.dart';
import 'web_socket_controller_initialize_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ConnectWebSocketInteractor>(),
  MockSpec<WebSocketChannel>(),
  MockSpec<WebSocketSink>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mine = AccountId(Id('mine'));
  final other = AccountId(Id('other'));
  final session = SessionFixtures.aliceSession;

  late MockConnectWebSocketInteractor connectInteractor;
  late MockWebSocketSink sink;
  late StreamController<dynamic> frames;
  late WebSocketController controller;

  setUp(() {
    dotenv.testLoad();
    connectInteractor = MockConnectWebSocketInteractor();
    sink = MockWebSocketSink();
    frames = StreamController<dynamic>.broadcast();
    when(connectInteractor.execute(any, any)).thenAnswer((_) {
      final channel = MockWebSocketChannel();
      when(channel.sink).thenReturn(sink);
      when(channel.stream).thenAnswer((_) => frames.stream);
      return Stream.value(Right(WebSocketConnectionSuccess(channel)));
    });
    Get.put<ConnectWebSocketInteractor>(connectInteractor);
    controller = WebSocketController.forTesting(
      emailChangeListener: MockEmailChangeListener(),
      mailboxChangeListener: MockMailboxChangeListener(),
      labelChangeListener: MockLabelChangeListener(),
    );
  });

  tearDown(() async {
    controller.onClose();
    await frames.close();
    Get.reset();
  });

  List<List<dynamic>> sentPushTypes() => verify(sink.add(captureAny))
      .captured
      .map((frame) => (jsonDecode(frame as String) as Map)['dataTypes'] as List)
      .toList();

  final mailTypes = [TypeName.emailType.value, TypeName.mailboxType.value];
  final labelTypes = [...mailTypes, TypeName.labelType.value];

  Future<void> initialize(AccountId accountId, {required bool isLabelAvailable}) async {
    controller.initialize(accountId: accountId, session: session, isLabelAvailable: isLabelAvailable);
    await pumpEventQueue();
  }

  test('keeps the open socket and only resends its push types when the label flag changes', () async {
    await initialize(mine, isLabelAvailable: false);

    await initialize(mine, isLabelAvailable: true);

    verify(connectInteractor.execute(session, mine)).called(1);
    expect(sentPushTypes(), [mailTypes, labelTypes]);
    expect(controller.isLabelAvailable, isTrue);
  });

  test('SHOULD NOT reconnect or resend the push types when initialized again with the same label flag', () async {
    await initialize(mine, isLabelAvailable: true);

    await initialize(mine, isLabelAvailable: true);

    verify(connectInteractor.execute(session, mine)).called(1);
    expect(sentPushTypes(), [labelTypes]);
  });

  test('connects a new socket when initialized for another account', () async {
    await initialize(mine, isLabelAvailable: false);

    await initialize(other, isLabelAvailable: true);

    verify(connectInteractor.execute(session, mine)).called(1);
    verify(connectInteractor.execute(session, other)).called(1);
    expect(sentPushTypes(), [mailTypes, labelTypes]);
  });
}
