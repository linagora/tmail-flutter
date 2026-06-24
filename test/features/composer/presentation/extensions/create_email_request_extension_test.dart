import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';

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

  group('generateComposerCache', () {
    CreateEmailRequest makeRequest({String? composerId}) => CreateEmailRequest(
          session: SessionFixtures.aliceSession,
          accountId: AccountFixtures.aliceAccountId,
          emailActionType: EmailActionType.compose,
          ownEmailAddress: 'alice@domain.tld',
          subject: 'Test',
          emailContent: '<p>Hello</p>',
          composerId: composerId,
        );

    group('when isPersistent is true', () {
      test('returns ComposerPersistentCache', () {
        final cache = makeRequest().generateComposerCache(
          emailCreated: Email(),
          isPersistent: true,
        );

        expect(cache, isA<ComposerPersistentCache>());
      });

      test('sets actionType to restoreComposerFromPersistentCache', () {
        final cache = makeRequest().generateComposerCache(
          emailCreated: Email(),
          isPersistent: true,
        ) as ComposerPersistentCache;

        expect(cache.actionType, EmailActionType.restoreComposerFromPersistentCache);
      });

      test('sets isCleanClose to false', () {
        final cache = makeRequest().generateComposerCache(
          emailCreated: Email(),
          isPersistent: true,
        ) as ComposerPersistentCache;

        expect(cache.isCleanClose, isFalse);
      });

      test('sets timestampMs to a value within the current second', () {
        final before = DateTime.now().millisecondsSinceEpoch;
        final cache = makeRequest().generateComposerCache(
          emailCreated: Email(),
          isPersistent: true,
        ) as ComposerPersistentCache;
        final after = DateTime.now().millisecondsSinceEpoch;

        expect(cache.timestampMs, isNotNull);
        expect(cache.timestampMs, greaterThanOrEqualTo(before));
        expect(cache.timestampMs, lessThanOrEqualTo(after));
      });

      test('includes the generated email', () {
        final email = Email();
        final cache = makeRequest().generateComposerCache(
          emailCreated: email,
          isPersistent: true,
        );

        expect(cache.email, same(email));
      });

      test('preserves composerId from the request', () {
        const composerId = 'uuid-composer-abc';
        final cache = makeRequest(composerId: composerId).generateComposerCache(
          emailCreated: Email(),
          isPersistent: true,
        );

        expect(cache.composerId, composerId);
      });
    });

    group('when isPersistent is false (default)', () {
      test('returns plain ComposerCache, not ComposerPersistentCache', () {
        final cache = makeRequest().generateComposerCache(emailCreated: Email());

        expect(cache, isA<ComposerCache>());
        expect(cache, isNot(isA<ComposerPersistentCache>()));
      });

      test('preserves displayMode from the request', () {
        final cache = makeRequest().generateComposerCache(emailCreated: Email());

        expect(cache.displayMode, ScreenDisplayMode.normal);
      });
    });
  });

  group('createReplyToRecipients:', () {
    const ownEmail = 'alice@domain.tld';

    CreateEmailRequest buildRequest({
      Identity? identity,
      Set<EmailAddress>? replyToRecipients,
      String ownEmailAddress = ownEmail,
    }) {
      return CreateEmailRequest(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        emailActionType: EmailActionType.compose,
        ownEmailAddress: ownEmailAddress,
        subject: 'subject',
        emailContent: 'content',
        identity: identity,
        replyToRecipients: replyToRecipients,
      );
    }

    test(
      'should return own email address without display name '
      'when no identity is set',
    () {
      final request = buildRequest();

      final result = request.createReplyToRecipients();

      expect(result, {EmailAddress(null, ownEmail)});
    });

    test(
      'should return null '
      'when no identity is set and ownEmailAddress is empty',
    () {
      final request = buildRequest(ownEmailAddress: '');

      final result = request.createReplyToRecipients();

      expect(result, isNull);
    });

    test(
      'should return identity email with display name '
      'when identity has no replyTo configured',
    () {
      final identity = Identity(
        name: 'Alice Smith',
        email: ownEmail,
        replyTo: {},
      );
      final request = buildRequest(identity: identity);

      final result = request.createReplyToRecipients();

      expect(result, {EmailAddress('Alice Smith', ownEmail)});
    });

    test(
      'should supplement identity name on replyTo address '
      'when identity replyTo items have no display name',
    () {
      const replyToEmail = 'reply@domain.tld';
      final identity = Identity(
        name: 'Alice Smith',
        email: ownEmail,
        replyTo: {EmailAddress(null, replyToEmail)},
      );
      final request = buildRequest(identity: identity);

      final result = request.createReplyToRecipients();

      expect(result, {EmailAddress('Alice Smith', replyToEmail)});
    });

    test(
      'should preserve existing display name on replyTo address '
      'when replyTo items already have a display name',
    () {
      const replyToEmail = 'reply@domain.tld';
      final identity = Identity(
        name: 'Alice Smith',
        email: ownEmail,
        replyTo: {EmailAddress('Custom Name', replyToEmail)},
      );
      final request = buildRequest(identity: identity);

      final result = request.createReplyToRecipients();

      expect(result, {EmailAddress('Custom Name', replyToEmail)});
    });

    test(
      'should supplement identity name only on items missing display name '
      'when identity replyTo contains mixed items',
    () {
      const namedEmail = 'named@domain.tld';
      const unnamedEmail = 'unnamed@domain.tld';
      final identity = Identity(
        name: 'Alice Smith',
        email: ownEmail,
        replyTo: {
          EmailAddress('Custom Name', namedEmail),
          EmailAddress(null, unnamedEmail),
        },
      );
      final request = buildRequest(identity: identity);

      final result = request.createReplyToRecipients();

      expect(result, {
        EmailAddress('Custom Name', namedEmail),
        EmailAddress('Alice Smith', unnamedEmail),
      });
    });

    test(
      'should return null '
      'when isDraft is true regardless of identity',
    () {
      final identity = Identity(
        name: 'Alice Smith',
        email: ownEmail,
        replyTo: {EmailAddress(null, 'reply@domain.tld')},
      );
      final request = buildRequest(identity: identity);

      final result = request.createReplyToRecipients(isNotReplyTo: true);

      expect(result, isNull);
    });

    test(
      'should return manually set replyToRecipients as-is '
      'when replyToRecipients is provided',
    () {
      final manualReplyTo = {EmailAddress('Bob', 'bob@domain.tld')};
      final identity = Identity(
        name: 'Alice Smith',
        email: ownEmail,
        replyTo: {EmailAddress(null, 'reply@domain.tld')},
      );
      final request = buildRequest(
        identity: identity,
        replyToRecipients: manualReplyTo,
      );

      final result = request.createReplyToRecipients();

      expect(result, manualReplyTo);
    });
  });
}