import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';

void main() {
  final mailboxId = MailboxId(Id('mailbox1'));
  final mailbox = PresentationMailbox(mailboxId);
  final syncContext = PresentationEmailSyncContext(
    mapMailboxById: {mailboxId: mailbox},
  );

  PresentationEmail email(
    String id, {
    SelectMode selectMode = SelectMode.INACTIVE,
  }) =>
      PresentationEmail(
        id: EmailId(Id(id)),
        mailboxIds: {mailboxId: true},
        selectMode: selectMode,
      );

  group('ListPresentationEmailExtensions::toSyncedSearchResults', () {
    test(
      'SHOULD return the full mapped list (same length as the input page)\n'
      'AND NOT append it to previousList — the executor already accumulates',
      () {
        final emails = [email('e1'), email('e2'), email('e3')];

        final result = emails.toSyncedSearchResults(
          context: syncContext,
          previousList: [email('old')],
        );

        expect(result.length, 3);
        expect(
          result.map((e) => e.id?.id.value).toList(),
          ['e1', 'e2', 'e3'],
        );
      },
    );

    test(
      'SHOULD carry the current selection forward by id from previousList',
      () {
        final emails = [email('e1'), email('e2'), email('e3')];
        final previousList = [email('e2', selectMode: SelectMode.ACTIVE)];

        final result = emails.toSyncedSearchResults(
          context: syncContext,
          previousList: previousList,
        );

        final byId = {for (final e in result) e.id?.id.value: e};
        expect(byId['e2']?.selectMode, SelectMode.ACTIVE);
        expect(byId['e1']?.selectMode, SelectMode.INACTIVE);
        expect(byId['e3']?.selectMode, SelectMode.INACTIVE);
      },
    );

    test(
      'SHOULD resolve each row mailboxContain from mapMailboxById',
      () {
        final result = [email('e1')].toSyncedSearchResults(
          context: syncContext,
          previousList: const [],
        );

        expect(result.single.mailboxContain, mailbox);
      },
    );

    test('SHOULD return an empty list WHEN the page is empty', () {
      final result = <PresentationEmail>[].toSyncedSearchResults(
        context: syncContext,
        previousList: [email('old', selectMode: SelectMode.ACTIVE)],
      );

      expect(result, isEmpty);
    });
  });
}
