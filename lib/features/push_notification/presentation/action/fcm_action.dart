
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class SynchronizeEmailOnForegroundAction extends FcmStateChangeAction {

  final AccountId accountId;

  SynchronizeEmailOnForegroundAction(
    TypeName typeName,
    jmap.State newState,
    this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}

class PushNotificationAction extends FcmStateChangeAction {

  final AccountId accountId;

  PushNotificationAction(
    TypeName typeName,
    jmap.State newState,
    this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}

class StoreEmailStateToRefreshAction extends FcmStateChangeAction {

  final AccountId accountId;

  StoreEmailStateToRefreshAction(
    TypeName typeName,
    jmap.State newState,
    this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}

class SynchronizeMailboxOnForegroundAction extends FcmStateChangeAction {

  final AccountId accountId;

  SynchronizeMailboxOnForegroundAction(
      TypeName typeName,
      jmap.State newState,
      this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}

class StoreMailboxStateToRefreshAction extends FcmStateChangeAction {

  final AccountId accountId;

  StoreMailboxStateToRefreshAction(
      TypeName typeName,
      jmap.State newState,
      this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}