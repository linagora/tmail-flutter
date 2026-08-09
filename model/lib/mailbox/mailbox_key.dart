import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

/// The real primary key of a mailbox.
///
/// RFC 8620 section 1.2: "The id MUST be unique among all records of the same
/// type within the same account. Ids may clash across accounts or for two
/// records of different types within the same account."
///
/// A bare [MailboxId] is therefore only meaningful alongside the account that
/// owns it. Anything that looks a mailbox up, selects one, routes to one or
/// dispatches an action against one must key on this pair, otherwise a mailbox
/// belonging to another user's account can be mistaken for one of the primary
/// account's mailboxes.
class MailboxKey with EquatableMixin {

  /// The account of app-local pseudo-mailboxes: the virtual folders (Starred,
  /// Needs action, unified inbox) and the root sentinel node.
  ///
  /// These are client-side constructs with no server-side counterpart, so they
  /// genuinely have no owning JMAP account. Giving them one shared namespace
  /// keeps [PresentationMailbox.key] total, so no caller has to special-case
  /// them. Mailboxes that came from the server always carry the account they
  /// were fetched from, stamped on by the interactor that fetched them.
  ///
  /// The value has to satisfy the JMAP Id grammar (RFC 8620: leading
  /// alphanumeric, then alphanumerics, hyphen or underscore), so it cannot be
  /// marked with a leading underscore.
  static final AccountId localAccount = AccountId(Id('tmailLocalPseudoAccount'));

  final AccountId accountId;
  final MailboxId mailboxId;

  const MailboxKey(this.accountId, this.mailboxId);

  String get asString => '${accountId.id.value}:${mailboxId.id.value}';

  @override
  List<Object?> get props => [accountId, mailboxId];

  @override
  String toString() => 'MailboxKey($asString)';
}
