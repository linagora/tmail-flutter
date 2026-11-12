import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

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

  group('EmailPreviewerController.previewedAccountId', () {
    final session = DelegationFixtures.session();

    AccountId previewed(Map<String, dynamic> parameters) =>
        EmailPreviewerController.previewedAccountId(session, parameters);

    test('uses the delegated account named by the URL', () {
      expect(
        previewed({RouteUtils.paramAccount: DelegationFixtures.bobAccountId.id.value}),
        DelegationFixtures.bobAccountId,
      );
    });

    test('uses mine for a URL without an account', () {
      expect(previewed({}), DelegationFixtures.aliceAccountId);
    });

    test('should not use an account the session does not list', () {
      expect(
        previewed({RouteUtils.paramAccount: DelegationFixtures.unknownAccountId.id.value}),
        DelegationFixtures.aliceAccountId,
      );
    });
  });

  group('EmailPreviewerController.emlPreviewUriOnAccount', () {
    final emlPreviewUri = Uri.parse('https://mail.example.com/mail/eml/preview?id=blob1');
    final bobLink = Uri.parse(
      'https://mail.example.com/mail/eml/preview?id=blob1&account=${DelegationFixtures.bobAccountId.id.value}',
    );

    test('adds the account of a delegated tab to a nested link', () {
      expect(
        EmailPreviewerController.emlPreviewUriOnAccount(emlPreviewUri, DelegationFixtures.bobAccountId),
        bobLink,
      );
    });

    test('leaves a nested link of my own tab without account', () {
      expect(EmailPreviewerController.emlPreviewUriOnAccount(emlPreviewUri, null), emlPreviewUri);
    });

    test('replaces the account a message put in the link by the account of the tab', () {
      final carolLink = Uri.parse(
        'https://mail.example.com/mail/eml/preview?id=blob1&account=${DelegationFixtures.carolAccountId.id.value}',
      );

      expect(
        EmailPreviewerController.emlPreviewUriOnAccount(carolLink, DelegationFixtures.bobAccountId),
        bobLink,
      );
      expect(EmailPreviewerController.emlPreviewUriOnAccount(carolLink, null), emlPreviewUri);
    });
  });
}
