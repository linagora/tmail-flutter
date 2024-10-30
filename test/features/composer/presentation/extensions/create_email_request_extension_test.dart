import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
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
    subject: 'subject',
    emailContent: 'emailContent',
    fromSender: {},
    toRecipients: {},
    ccRecipients: {},
    bccRecipients: {},
    replyToRecipients: {},
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
  });
}