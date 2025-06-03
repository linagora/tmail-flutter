import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

void main() {
  group('MailboxWidgetMixin::isSubaddressingSupported::test', () {

    test(
        'should return true '
            'when the server advertizes true',
            () {

          // arrange
          final session = Session(
              {CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({"subaddressingSupported": true})},
              {AccountId(Id("1")): Account(AccountName("name"), true, false, {CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({"subaddressingSupported": true})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final isSubAddressingSupported = session.isSubAddressingSupported(AccountId(Id("1")));

          // assert
          expect(isSubAddressingSupported, true);
        });

    test(
        'should return false '
            'when the server advertizes false',
            () {

          // arrange
          final session = Session(
              {CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({"subaddressingSupported": false})},
              {AccountId(Id("1")): Account(AccountName("name"), true, false, {CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({"subaddressingSupported": false})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final isSubAddressingSupported = session.isSubAddressingSupported(AccountId(Id("1")));

          // assert
          expect(isSubAddressingSupported, false);
        });

    test(
        'should return false '
            'when the server advertizes nothing',
            () {

          // arrange
          final session = Session(
              {CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({})},
              {AccountId(Id("1")): Account(AccountName("name"), true, false, {CapabilityIdentifier.jmapTeamMailboxes: DefaultCapability({})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final isSubAddressingSupported = session.isSubAddressingSupported(AccountId(Id("1")));

          // assert
          expect(isSubAddressingSupported, false);
        });
  });
}