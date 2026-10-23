import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class ActiveAccount with EquatableMixin {
  final Session session;
  final AccountId accountId;

  ActiveAccount.personal(this.session) : accountId = session.accountId;

  ActiveAccount.delegated(this.session, this.accountId)
      : assert(session.isDelegatedAccount(accountId));

  AccountId get personalAccountId => session.accountId;

  bool get isDelegated => accountId != personalAccountId;

  String get ownerEmailAddress => isDelegated
      ? session.accounts[accountId]!.name.value
      : session.getOwnEmailAddressOrEmpty();

  bool supportsCapability(CapabilityIdentifier capability) =>
      capability.isSupported(session, accountId);

  @override
  List<Object?> get props => [session, accountId];
}
