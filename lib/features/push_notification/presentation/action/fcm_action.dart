
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

class StoreEmailStateChangeToRefreshAction extends FcmStateChangeAction {

  final AccountId accountId;

  StoreEmailStateChangeToRefreshAction(
    TypeName typeName,
    jmap.State newState,
    this.accountId
  ) : super(typeName, newState);

  @override
  List<Object?> get props => [typeName, newState, accountId];
}