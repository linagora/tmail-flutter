import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

void main() {
  final createEmailRequest = CreateEmailRequest(
    session: SessionFixtures.aliceSession,
    accountId: AccountFixtures.aliceAccountId,
    emailActionType: EmailActionType.editDraft,
    ownEmailAddress: SessionFixtures
      .aliceSession
      .getOwnEmailAddressOrEmpty(),
    subject: 'subject',
    emailContent: 'emailContent',
  );

  group('create email request extension test:', () {
    test(
      'should return email with identity header '
      'when generateEmail is called '
      'and withIdentityHeader is true',
    () {
      // act
      final result = createEmailRequest.generateEmail(
        newEmailContent: 'newEmailContent',
        newEmailAttachments: {},
        userAgent: 'userAgent',
        partId: PartId('value'),
        withIdentityHeader: true
      );
      
      // assert
      expect(
        result.identityHeader?.containsKey(
          IndividualHeaderIdentifier.identityHeader),
        isTrue);
    });

    test(
      'should return email without identity header '
      'when generateEmail is called '
      'and withIdentityHeader is false',
    () {
      // act
      final result = createEmailRequest.generateEmail(
        newEmailContent: 'newEmailContent',
        newEmailAttachments: {},
        userAgent: 'userAgent',
        partId: PartId('value'),
        withIdentityHeader: false
      );
      
      // assert
      expect(result.identityHeader, isNull);
    });

    test(
      'should return email with mdn and return path headers '
      'when generateEmail is called '
      'and hasRequestReadReceipt is true',
    () {
      // arrange
      final createEmailRequest = CreateEmailRequest(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        emailActionType: EmailActionType.editDraft,
        ownEmailAddress: SessionFixtures
          .aliceSession
          .getOwnEmailAddressOrEmpty(),
        subject: 'subject',
        emailContent: 'emailContent',
        hasRequestReadReceipt: true,
      );
      
      // act
      final result = createEmailRequest.generateEmail(
        newEmailContent: 'newEmailContent',
        newEmailAttachments: {},
        userAgent: 'userAgent',
        partId: PartId('value'),
        withIdentityHeader: false
      );
      
      // assert
      expect(
        result.headerMdn?[IndividualHeaderIdentifier.headerMdn],
        createEmailRequest.createMdnEmailAddress(),
      );
      expect(
        result.headerReturnPath?[IndividualHeaderIdentifier.headerReturnPath],
        createEmailRequest.createMdnEmailAddress(),
      );
    });
  });

  group('CreateEmailRequestExtension.createKeywords', () {
    late Session session;
    late AccountId accountId;

    setUp(() {
      session = SessionFixtures.aliceSession;
      accountId = AccountFixtures.aliceAccountId;
    });

    CreateEmailRequest buildRequest({
      MailboxId? draftsMailboxId,
      MailboxId? templateMailboxId,
      List<KeyWordIdentifier>? keywords,
    }) {
      return CreateEmailRequest(
        session: session,
        accountId: accountId,
        emailActionType: EmailActionType.compose,
        ownEmailAddress: 'user@example.com',
        subject: 'subject',
        emailContent: 'content',
        draftsMailboxId: draftsMailboxId,
        templateMailboxId: templateMailboxId,
        keywords: keywords,
      );
    }

    test('returns null when drafts, template and keywords are all null', () {
      final request = buildRequest();

      final result = request.createKeywords();

      expect(result, isNull);
    });

    test('returns \$draft and \$seen when draftsMailboxId is provided', () {
      final request = buildRequest(
        draftsMailboxId: MailboxId(Id('drafts')),
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailDraft: true,
        KeyWordIdentifier.emailSeen: true,
      });
    });

    test('returns only \$seen when templateMailboxId is provided', () {
      final request = buildRequest(
        templateMailboxId: MailboxId(Id('template')),
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailSeen: true,
      });
    });

    test('returns only custom keywords when keywords is provided alone', () {
      final request = buildRequest(
        keywords: [
          KeyWordIdentifier.emailFlagged,
          KeyWordIdentifier.emailAnswered,
        ],
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailFlagged: true,
        KeyWordIdentifier.emailAnswered: true,
      });
    });

    test('merges drafts keywords with custom keywords', () {
      final request = buildRequest(
        draftsMailboxId: MailboxId(Id('drafts')),
        keywords: [
          KeyWordIdentifier.emailFlagged,
        ],
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailDraft: true,
        KeyWordIdentifier.emailSeen: true,
        KeyWordIdentifier.emailFlagged: true,
      });
    });

    test('merges template keywords with custom keywords', () {
      final request = buildRequest(
        templateMailboxId: MailboxId(Id('template')),
        keywords: [
          KeyWordIdentifier.emailFlagged,
        ],
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailSeen: true,
        KeyWordIdentifier.emailFlagged: true,
      });
    });

    test('does not duplicate \$seen if provided in custom keywords', () {
      final request = buildRequest(
        templateMailboxId: MailboxId(Id('template')),
        keywords: [
          KeyWordIdentifier.emailSeen,
          KeyWordIdentifier.emailFlagged,
        ],
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailSeen: true,
        KeyWordIdentifier.emailFlagged: true,
      });
    });

    test('does not duplicate \$draft if provided in custom keywords', () {
      final request = buildRequest(
        draftsMailboxId: MailboxId(Id('drafts')),
        keywords: [
          KeyWordIdentifier.emailDraft,
        ],
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailDraft: true,
        KeyWordIdentifier.emailSeen: true,
      });
    });

    test('handles multiple custom keywords correctly', () {
      final request = buildRequest(
        draftsMailboxId: MailboxId(Id('drafts')),
        keywords: [
          KeyWordIdentifier.emailFlagged,
          KeyWordIdentifier.emailAnswered,
          KeyWordIdentifier.emailForwarded,
        ],
      );

      final result = request.createKeywords();

      expect(result, {
        KeyWordIdentifier.emailDraft: true,
        KeyWordIdentifier.emailSeen: true,
        KeyWordIdentifier.emailFlagged: true,
        KeyWordIdentifier.emailAnswered: true,
        KeyWordIdentifier.emailForwarded: true,
      });
    });
  });
}