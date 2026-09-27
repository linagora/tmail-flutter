import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class _MailboxWidgetMixinHolder with MailboxWidgetMixin {}

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

  group('MailboxWidgetMixin::listContextMenuItemAction::openInNewTab', () {
    final mixinHolder = _MailboxWidgetMixinHolder();
    final teamNamespace = Namespace('Delegated[team@example.com]');

    setUp(() => PlatformInfo.isTestingForWeb = true);
    tearDown(() => PlatformInfo.isTestingForWeb = false);

    List<MailboxActions> actionsOf(PresentationMailbox mailbox) =>
        mixinHolder
            .listContextMenuItemAction(
              mailbox,
              false,
              false,
              false,
              ImagePaths(),
              AppLocalizations(),
            )
            .map((item) => item.action)
            .toList();

    test(
      'should not offer open in new tab for a team mailbox root',
      () {
        final teamMailboxRoot = PresentationMailbox(
          MailboxId(Id('team-root')),
          namespace: teamNamespace,
          isSubscribed: IsSubscribed(true),
        );

        expect(
          actionsOf(teamMailboxRoot),
          isNot(contains(MailboxActions.openInNewTab)),
        );
      },
    );

    test(
      'should offer open in new tab for a team mailbox child folder',
      () {
        final teamMailboxChild = PresentationMailbox(
          MailboxId(Id('team-inbox')),
          parentId: MailboxId(Id('team-root')),
          namespace: teamNamespace,
          isSubscribed: IsSubscribed(true),
        );

        expect(
          actionsOf(teamMailboxChild),
          contains(MailboxActions.openInNewTab),
        );
      },
    );
  });
}