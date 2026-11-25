import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';

/// The delegated mailbox a notification belongs to (ADR-0114 Sync).
class NotificationOwner with EquatableMixin {
  final AccountId accountId;
  final String name;

  const NotificationOwner({required this.accountId, required this.name});

  /// Null for my own account or an account [session] does not list as delegated.
  static NotificationOwner? of(Session? session, AccountId accountId) {
    if (session == null || !session.isDelegatedAccount(accountId)) return null;
    return NotificationOwner(
      accountId: accountId,
      name: session.accounts[accountId]!.name.value,
    );
  }

  @override
  List<Object?> get props => [accountId, name];
}
