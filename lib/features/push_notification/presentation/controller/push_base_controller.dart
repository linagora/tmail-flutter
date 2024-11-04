import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';

abstract class PushBaseController {
  Session? session;
  AccountId? accountId;

  void consumeState(Stream<Either<Failure, Success>> newStateStream) {
    newStateStream.listen(
      _handleStateStream,
      onError: handleErrorViewState,
    );
  }

  void _handleStateStream(Either<Failure, Success> newState) {
    newState.fold(handleFailureViewState, handleSuccessViewState);
  }

  void handleFailureViewState(Failure failure);

  void handleSuccessViewState(Success success);

  void handleErrorViewState(Object error, StackTrace stackTrace) {
    logError('PushBaseController::handleErrorViewState():error: $error | stackTrace: $stackTrace');
  }

  void initialize({AccountId? accountId, Session? session}) {
    this.accountId = accountId;
    this.session = session;
  }

  void mappingTypeStateToAction(
    Map<String, dynamic> mapTypeState,
    AccountId accountId,
    UserName userName, {
    bool isForeground = true,
    Session? session,
    required EmailChangeListener emailChangeListener,
    required MailboxChangeListener mailboxChangeListener
  }) {
    log('PushBaseController::mappingTypeStateToAction():mapTypeState: $mapTypeState');
    final listTypeName = mapTypeState.keys
      .map((value) => TypeName(value))
      .toList();

    final listEmailActions = listTypeName
      .where((typeName) => typeName == TypeName.emailType || typeName == TypeName.emailDelivery)
      .map((typeName) => _toPushNotificationAction(typeName, accountId, userName, mapTypeState, isForeground, session: session))
      .whereNotNull()
      .toList();

    log('PushBaseController::mappingTypeStateToAction():listEmailActions: $listEmailActions');

    if (listEmailActions.isNotEmpty) {
       emailChangeListener.dispatchActions(listEmailActions);
    }

    final listMailboxActions = listTypeName
      .where((typeName) => typeName == TypeName.mailboxType)
      .map((typeName) => _toPushNotificationAction(typeName, accountId, userName, mapTypeState, isForeground))
      .whereNotNull()
      .toList();

    log('PushBaseController::mappingTypeStateToAction():listMailboxActions: $listEmailActions');

    if (listMailboxActions.isNotEmpty) {
      mailboxChangeListener.dispatchActions(listMailboxActions);
    }
  }

  PushNotificationStateChangeAction? _toPushNotificationAction(
    TypeName typeName,
    AccountId accountId,
    UserName userName,
    Map<String, dynamic> mapTypeState,
    isForeground,
    {Session? session}
  ) {
    final newState = jmap.State(mapTypeState[typeName.value]);
    switch (typeName) {
      case TypeName.emailType:
        return isForeground
            ? SynchronizeEmailOnForegroundAction(typeName, newState, accountId, session)
            : StoreEmailStateToRefreshAction(typeName, newState, accountId, userName, session);
      case TypeName.emailDelivery:
        if (!isForeground) {
          return PushNotificationAction(typeName, newState, session, accountId, userName);
        }
        break;
      case TypeName.mailboxType:
        return isForeground
            ? SynchronizeMailboxOnForegroundAction(typeName, newState, accountId)
            : StoreMailboxStateToRefreshAction(typeName, newState, accountId, userName);
    }
    return null;
  }
}