import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/saved_email_draft.dart';

void main() {
  group('saved email draft test', () {
    test(
      'should tag toRecipients, ccRecipients and bccRecipients in props',
    () {
      // arrange
      final savedEmailDraft = SavedEmailDraft(
        subject: 'subject',
        content: 'content',
        toRecipients: {EmailAddress('to name', 'to email')},
        ccRecipients: {EmailAddress('cc name', 'cc email')},
        bccRecipients: {EmailAddress('bcc name', 'bcc email')},
        identity: null,
        attachments: [],
        hasReadReceipt: false
      );
      
      // act
      final props = savedEmailDraft.props;
      
      // assert
      expect(props[2], equals({0: savedEmailDraft.toRecipients}));
      expect(props[3], equals({1: savedEmailDraft.ccRecipients}));
      expect(props[4], equals({2: savedEmailDraft.bccRecipients}));
    });

    test(
      'should generate different hashcode '
      'when toRecipients, ccRecipients and bccRecipients are different',
    () {
      // arrange
      const subject = 'subject';
      const content = 'content';
      final recipent = EmailAddress('recipent name', 'recipent email');
      final identity = Identity();
      final attachments = <Attachment>[];
      const hasReadReceipt = false;

      final toSavedEmailDraft = SavedEmailDraft(
        subject: subject,
        content: content,
        toRecipients: {recipent},
        ccRecipients: {},
        bccRecipients: {},
        identity: identity,
        attachments: attachments,
        hasReadReceipt: hasReadReceipt
      );

      final ccSavedEmailDraft = SavedEmailDraft(
        subject: subject,
        content: content,
        toRecipients: {},
        ccRecipients: {recipent},
        bccRecipients: {},
        identity: identity,
        attachments: attachments,
        hasReadReceipt: hasReadReceipt
      );

      final bccSavedEmailDraft = SavedEmailDraft(
        subject: subject,
        content: content,
        toRecipients: {},
        ccRecipients: {},
        bccRecipients: {recipent},
        identity: identity,
        attachments: attachments,
        hasReadReceipt: hasReadReceipt
      );
      
      // act
      final toProps = toSavedEmailDraft.props;
      final ccProps = ccSavedEmailDraft.props;
      final bccProps = bccSavedEmailDraft.props;
      
      // assert
      expect(toProps.hashCode, isNot(ccProps.hashCode));
      expect(ccProps.hashCode, isNot(bccProps.hashCode));
      expect(bccProps.hashCode, isNot(toProps.hashCode));
    });

    test(
      'should generate different hashcode '
      'when toRecipients is updated',
    () {
      // arrange
      final listToRecipients = {
        EmailAddress('to name', 'to email')
      };
      final savedEmailDraft = SavedEmailDraft(
          subject: 'subject',
          content: 'content',
          toRecipients: listToRecipients,
          ccRecipients: {EmailAddress('cc name', 'cc email')},
          bccRecipients: {EmailAddress('bcc name', 'bcc email')},
          identity: null,
          attachments: [],
          hasReadReceipt: false
      );
      final hashCodeBeforeChange = savedEmailDraft.hashCode;

      // act
      listToRecipients.add(EmailAddress('to name 2', 'to email 2'));
      final hashCodeAfterChange = savedEmailDraft.hashCode;

      // assert
      expect(hashCodeBeforeChange, isNot(hashCodeAfterChange));
    });

    test(
      'should generate same hashcode '
      'when all properties are the same',
    () {
      // arrange
      final savedEmailDraft = SavedEmailDraft(
        subject: 'subject',
        content: 'content',
        toRecipients: {EmailAddress('to name', 'to email')},
        ccRecipients: {EmailAddress('cc name', 'cc email')},
        bccRecipients: {EmailAddress('bcc name', 'bcc email')},
        identity: null,
        attachments: [],
        hasReadReceipt: false
      );

      final savedEmailDraft2 = SavedEmailDraft(
        subject: 'subject',
        content: 'content',
        toRecipients: {EmailAddress('to name', 'to email')},
        ccRecipients: {EmailAddress('cc name', 'cc email')},
        bccRecipients: {EmailAddress('bcc name', 'bcc email')},
        identity: null,
        attachments: [],
        hasReadReceipt: false
      );

      // assert
      expect(savedEmailDraft.hashCode, equals(savedEmailDraft2.hashCode));
    });
  });
}