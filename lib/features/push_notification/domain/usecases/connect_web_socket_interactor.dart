import 'dart:convert';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/web_socket_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/web_socket_push_state.dart';

class ConnectWebSocketInteractor {
  final WebSocketRepository _webSocketRepository;

  ConnectWebSocketInteractor(this._webSocketRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId
  ) async* {
    try {
      yield Right(InitializingWebSocketPushChannel());
      yield* _webSocketRepository
        .getWebSocketChannel(session, accountId)
        .map(_toStateChange);
    } catch (e) {
      logError('ConnectWebSocketInteractor::execute: $e');
      yield Left(WebSocketConnectionFailed(exception: e));
    }
  }

  Either<Failure, Success> _toStateChange(dynamic data) {
    if (data is String) {
      data = jsonDecode(data);
    }
    return Right(WebSocketPushStateReceived(StateChange.fromJson(data)));
  }
}