import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';

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

  static Session session({
    String username = aliceAddress,
    String state = 'state-1',
    bool listsBob = true,
    bool listsCarol = true,
  }) {
    return Session(
      {personalOnlyCapability: DefaultCapability(<String, dynamic>{})},
      {
        aliceAccountId: Account(
          AccountName(aliceAddress),
          true,
          false,
          {personalOnlyCapability: DefaultCapability(<String, dynamic>{})},
        ),
        if (listsBob) bobAccountId: _delegatedAccount(bobAddress),
        if (listsCarol) carolAccountId: _delegatedAccount(carolAddress),
      },
      {},
      UserName(username),
      Uri.parse('http://domain.com/jmap'),
      Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
      Uri.parse('http://domain.com/upload/{accountId}'),
      Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
      State(state),
    );
  }

  static Account _delegatedAccount(String ownerAddress) => Account(
        AccountName(ownerAddress),
        false,
        false,
        {delegatedOnlyCapability: DefaultCapability(<String, dynamic>{})},
      );
}
