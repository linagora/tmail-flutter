import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

import 'account_fixtures.dart';

class DelegationFixtures {
  static const aliceAddress = 'alice@domain.tld';
  static const bobAddress = 'bob@domain.tld';
  static const carolAddress = 'carol@domain.tld';

  static final aliceAccountId = AccountFixtures.aliceAccountId;
  static final bobAccountId = AccountId(Id('bob-account-id'));
  static final carolAccountId = AccountId(Id('carol-account-id'));
  static final unknownAccountId = AccountId(Id('unknown-account-id'));

  static final personalOnlyCapability = CapabilityIdentifier.jmapVacationResponse;
  static final delegatedOnlyCapability = CapabilityIdentifier.jmapMdn;
  static final sharedCapability = CapabilityIdentifier.jmapQuota;

  static Session session({
    String username = aliceAddress,
    String state = 'state-1',
    bool listsBob = true,
    bool listsCarol = true,
  }) {
    return Session(
      {
        personalOnlyCapability: DefaultCapability(<String, dynamic>{}),
        delegationCapability: DefaultCapability(<String, dynamic>{}),
      },
      _accounts(listsBob: listsBob, listsCarol: listsCarol),
      {},
      UserName(username),
      Uri.parse('http://domain.com/jmap'),
      Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
      Uri.parse('http://domain.com/upload/{accountId}'),
      Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
      State(state),
    );
  }

  /// Same as [session] but without `urn:apache:james:params:jmap:delegation`.
  static Session sessionWithoutDelegationCapability({
    String username = aliceAddress,
    String state = 'state-1',
    bool listsBob = true,
    bool listsCarol = true,
  }) {
    return Session(
      {
        personalOnlyCapability: DefaultCapability(<String, dynamic>{}),
      },
      _accounts(listsBob: listsBob, listsCarol: listsCarol),
      {},
      UserName(username),
      Uri.parse('http://domain.com/jmap'),
      Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
      Uri.parse('http://domain.com/upload/{accountId}'),
      Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
      State(state),
    );
  }

  /// [session] with Bob's delegated account replaced by one that has exactly [capabilities], and
  /// my own account given [myExtraCapabilities] on top of its usual ones.
  static Session sessionWithBobCapabilities(
    Set<CapabilityIdentifier> capabilities, {
    Set<CapabilityIdentifier> myExtraCapabilities = const {},
  }) {
    final base = session();
    final mine = base.accounts[aliceAccountId]!;
    return Session(
      base.capabilities,
      {
        ...base.accounts,
        aliceAccountId: Account(mine.name, true, false, {
          ...mine.accountCapabilities,
          for (final capability in myExtraCapabilities) capability: DefaultCapability(<String, dynamic>{}),
        }),
        bobAccountId: Account(AccountName(bobAddress), false, false, {
          for (final capability in capabilities) capability: DefaultCapability(<String, dynamic>{}),
        }),
      },
      base.primaryAccounts,
      base.username,
      base.apiUrl,
      base.downloadUrl,
      base.uploadUrl,
      base.eventSourceUrl,
      base.state,
    );
  }

  /// Turns the local "Delegation" preference on in [container].
  static void turnDelegationOn(ProviderContainer container) => container
      .read(localSettingsProvider.notifier)
      .update(PreferencesSetting([DelegationConfig(isEnabled: true)]));

  static Map<AccountId, Account> _accounts({
    required bool listsBob,
    required bool listsCarol,
  }) =>
      {
        aliceAccountId: Account(
          AccountName(aliceAddress),
          true,
          false,
          {
            personalOnlyCapability: DefaultCapability(<String, dynamic>{}),
            sharedCapability: DefaultCapability(<String, dynamic>{}),
          },
        ),
        if (listsBob) bobAccountId: _delegatedAccount(bobAddress),
        if (listsCarol) carolAccountId: _delegatedAccount(carolAddress),
      };

  static Account _delegatedAccount(String ownerAddress) => Account(
        AccountName(ownerAddress),
        false,
        false,
        {
          delegatedOnlyCapability: DefaultCapability(<String, dynamic>{}),
          sharedCapability: DefaultCapability(<String, dynamic>{}),
          // A delegated account without it is not openable (SessionDelegationExtension).
          CapabilityIdentifier.jmapMail: DefaultCapability(<String, dynamic>{}),
        },
      );
}
