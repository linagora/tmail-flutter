
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';

class IdentityCreatorArguments with EquatableMixin {
  final AccountId accountId;
  final Session session;
  final IdentityActionType actionType;
  final Identity? identity;

  IdentityCreatorArguments(
    this.accountId,
    this.session,
    {
      this.identity,
      this.actionType = IdentityActionType.create
    }
  );

  @override
  List<Object?> get props => [
    accountId, 
    session, 
    identity,
    actionType];
}