import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';

import '../../fixtures/delegation_fixtures.dart';

void main() {
  group('EmailPreviewerController.opensWithNoOpener', () {
    test('cuts the opener for a web link', () {
      expect(
        EmailPreviewerController.opensWithNoOpener(
          Uri.parse('https://example.com'),
          isEmlPreview: false,
        ),
        isTrue,
      );
    });

    test('keeps the opener for the EML preview route', () {
      expect(
        EmailPreviewerController.opensWithNoOpener(
          Uri.parse('https://mail.example.com/previewer?id=1'),
          isEmlPreview: true,
        ),
        isFalse,
      );
    });

    test('keeps the opener for a mailto link', () {
      expect(
        EmailPreviewerController.opensWithNoOpener(
          Uri.parse('mailto:bob@example.com'),
          isEmlPreview: false,
        ),
        isFalse,
      );
    });
  });

  group('EmailPreviewerController.previewAccountId', () {
    final session = DelegationFixtures.session();

    test('opens my own account when the URL has no account', () {
      expect(
        EmailPreviewerController.previewAccountId(session, null),
        DelegationFixtures.aliceAccountId,
      );
    });

    test('opens the delegated account named in the URL', () {
      expect(
        EmailPreviewerController.previewAccountId(
          session,
          DelegationFixtures.bobAccountId.id.value,
        ),
        DelegationFixtures.bobAccountId,
      );
    });

    test('SHOULD NOT fall back to my own account for an account no longer delegated', () {
      expect(
        EmailPreviewerController.previewAccountId(
          DelegationFixtures.session(listsBob: false),
          DelegationFixtures.bobAccountId.id.value,
        ),
        isNull,
      );
    });

    test('SHOULD NOT open my own account named in the URL', () {
      expect(
        EmailPreviewerController.previewAccountId(
          session,
          DelegationFixtures.aliceAccountId.id.value,
        ),
        isNull,
      );
    });

    test('SHOULD NOT open an account that is not an id of the session', () {
      for (final accountParam in ['', 'not an id', DelegationFixtures.unknownAccountId.id.value]) {
        expect(
          EmailPreviewerController.previewAccountId(session, accountParam),
          isNull,
          reason: accountParam,
        );
      }
    });
  });

  group('EmailPreviewerController.emlPreviewUriOnAccount', () {
    final emlPreviewUri = Uri.parse('https://mail.example.com/mail/eml/preview?id=blob1');

    test('adds the account of a delegated tab to a nested link', () {
      expect(
        EmailPreviewerController.emlPreviewUriOnAccount(emlPreviewUri, 'bob-account-id'),
        Uri.parse('https://mail.example.com/mail/eml/preview?id=blob1&account=bob-account-id'),
      );
    });

    test('leaves a nested link of my own tab without account', () {
      expect(
        EmailPreviewerController.emlPreviewUriOnAccount(emlPreviewUri, null),
        emlPreviewUri,
      );
    });

    test('replaces the account a message put in the link by the account of the tab', () {
      final linkWithAccount = Uri.parse(
        'https://mail.example.com/mail/eml/preview?id=blob1&account=carol-account-id',
      );

      expect(
        EmailPreviewerController.emlPreviewUriOnAccount(linkWithAccount, 'bob-account-id'),
        Uri.parse('https://mail.example.com/mail/eml/preview?id=blob1&account=bob-account-id'),
      );
      expect(
        EmailPreviewerController.emlPreviewUriOnAccount(linkWithAccount, null),
        emlPreviewUri,
      );
    });
  });
}
