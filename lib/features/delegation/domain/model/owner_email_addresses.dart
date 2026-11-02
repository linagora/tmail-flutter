import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

/// "Me" addresses of the shown account (ADR-0114): the owner address plus its identities,
/// without the other accounts of the session or the team mailboxes of the shown account.
Set<String> ownerEmailAddressesOf({
  required ActiveAccount account,
  Iterable<Identity> identities = const [],
  Iterable<String> teamMailboxEmails = const [],
}) {
  final owner = account.ownerEmailAddress;
  final excluded = {
    ...account.session.accounts.entries
        .where((entry) => entry.key != account.accountId)
        .map((entry) => entry.value.name.value),
    ...teamMailboxEmails.where((email) => email.isNotEmpty),
  };

  final addresses = <String>{};
  if (owner.isNotEmpty) {
    addresses.add(owner);
  }
  for (final identity in identities) {
    final email = identity.email;
    if (email == null || email.isEmpty) continue;
    if (excluded.contains(email)) continue;
    addresses.add(email);
  }
  return addresses;
}
