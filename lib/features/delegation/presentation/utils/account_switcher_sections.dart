import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef AccountSwitcherAvatarBuilder = Widget Function(String emailAddress);

/// Account menu sections from the session (address-only in v1).
List<LinagoraAccountSection<AccountId>> buildAccountSwitcherSections({
  required Session session,
  required AppLocalizations l10n,
  required AccountSwitcherAvatarBuilder avatarFor,
}) {
  final ownAddress = session.getOwnEmailAddressOrEmpty();
  return [
    LinagoraAccountSection(
      title: l10n.yourMailbox,
      items: [
        LinagoraAccountItem(
          id: session.accountId,
          name: ownAddress,
          // v1 is address-only. Omit email to avoid a duplicate line.
          avatar: avatarFor(ownAddress),
        ),
      ],
    ),
    LinagoraAccountSection(
      title: l10n.delegatedToYou,
      items: [
        for (final entry in session.delegatedAccounts)
          LinagoraAccountItem(
            id: entry.key,
            name: entry.value.name.value,
            avatar: avatarFor(entry.value.name.value),
          ),
      ],
    ),
  ];
}
