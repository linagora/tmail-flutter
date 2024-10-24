
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class SynchronizeEmailOnForegroundAction extends PushNotificationStateChangeAction {

  final AccountId accountId;
  final Session? session;

  SynchronizeEmailOnForegroundAction(
    TypeName typeName,
    jmap.State newState,
    this.accountId,
    this.session
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId, session];
}

class PushNotificationAction extends PushNotificationStateChangeAction {

  final Session? session;
  final AccountId accountId;
  final UserName userName;

  PushNotificationAction(
    TypeName typeName,
    jmap.State newState,
    this.session,
    this.accountId,
    this.userName
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId, session, userName];
}

class StoreEmailStateToRefreshAction extends PushNotificationStateChangeAction {

  final AccountId accountId;
  final UserName userName;
  final Session? session;

  StoreEmailStateToRefreshAction(
    TypeName typeName,
    jmap.State newState,
    this.accountId,
    this.userName,
    this.session
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId, session];
}

class SynchronizeMailboxOnForegroundAction extends PushNotificationStateChangeAction {

  final AccountId accountId;

  SynchronizeMailboxOnForegroundAction(
      TypeName typeName,
      jmap.State newState,
      this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}

class StoreMailboxStateToRefreshAction extends PushNotificationStateChangeAction {

  final AccountId accountId;
  final UserName userName;

  StoreMailboxStateToRefreshAction(
      TypeName typeName,
      jmap.State newState,
      this.accountId,
      this.userName
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId, userName];
}