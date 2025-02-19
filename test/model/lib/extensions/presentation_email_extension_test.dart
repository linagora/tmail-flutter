import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';

void main() {
  group('presentation email extension test', () {
    final userAEmailAddress = EmailAddress('User A', 'userA@domain.com');
    final userBEmailAddress = EmailAddress('User B', 'userB@domain.com');
    final userCEmailAddress = EmailAddress('User C', 'userC@domain.com');
    final userDEmailAddress = EmailAddress('User D', 'userD@domain.com');
    final userEEmailAddress = EmailAddress('User E', 'userE@domain.com');
    final replyToEmailAddress = EmailAddress('Reply To', 'replyToThis@domain.com');
    final replyToListEmailAddress = EmailAddress(null, 'replyToList@domain.com');

    group('GIVEN user A is the sender AND sends an email to user B and user E, cc to user C, bcc to user D', () {
      test('THEN user A clicks reply, generateRecipientsEmailAddressForComposer SHOULD return user B email + user E email to reply', () {
        final expectedResult = Tuple3([userBEmailAddress, userEEmailAddress], <EmailAddress>[], <EmailAddress>[]);

        final emailToReply = PresentationEmail(
          from: {userAEmailAddress},
          to: {userBEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.reply,
          isSender: true,
          userName: userAEmailAddress.emailAddress,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });

      test('THEN user A clicks reply all, generateRecipientsEmailAddressForComposer SHOULD return user B email + user E email to reply, user C email address to cc, user D email address to bcc', () {
        final expectedResult = Tuple3([userBEmailAddress, userEEmailAddress], <EmailAddress>[userCEmailAddress], <EmailAddress>[userDEmailAddress]);

        final emailToReply = PresentationEmail(
          from: {userAEmailAddress},
          to: {userBEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.replyAll,
          isSender: true,
          userName: userAEmailAddress.emailAddress,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });
    });

    group('GIVEN user B is the sender, SENDER configured the replyTo email AND send an email to user A and user E, cc to user C, bcc to user D', () {
      test('THEN user A click reply, generateRecipientsEmailAddressForComposer SHOULD return only replyToEmailAddress email to reply' , () {
        final expectedResult = Tuple3([replyToEmailAddress], <EmailAddress>[], <EmailAddress>[]);

        final emailToReply = PresentationEmail(
          from: {userBEmailAddress},
          replyTo: {replyToEmailAddress},
          to: {userAEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.reply,
          isSender: false,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });

      test('THEN user A clicks reply all, generateRecipientsEmailAddressForComposer SHOULD return replyToEmailAddress + user A email + user E email to reply, user C email address to cc, user D email address to bcc', () {
        final expectedResult = Tuple3([userAEmailAddress, userEEmailAddress, replyToEmailAddress], <EmailAddress>[userCEmailAddress], <EmailAddress>[userDEmailAddress]);

        final emailToReply = PresentationEmail(
          from: {userBEmailAddress},
          replyTo: {replyToEmailAddress},
          to: {userAEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.replyAll,
          isSender: false,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });
    });

    group('GIVEN user B is the sender, SENDER does not have the replyTo email AND sends an email to user A and user E, cc to user C, bcc to user D', () {
      test('THEN user A clicks reply, generateRecipientsEmailAddressForComposer SHOULD return only user B email to reply', () {
        final expectedResult = Tuple3([userBEmailAddress], <EmailAddress>[], <EmailAddress>[]);

        final emailToReply = PresentationEmail(
          from: {userBEmailAddress},
          to: {userAEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.reply,
          isSender: false,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });

      test('THEN user A clicks reply all, generateRecipientsEmailAddressForComposer SHOULD return user A email + user E email + user B email to reply, user C email to cc, user D email to bcc', () {
        final expectedResult = Tuple3([userAEmailAddress, userEEmailAddress, userBEmailAddress], <EmailAddress>[userCEmailAddress], <EmailAddress>[userDEmailAddress]);

        final emailToReply = PresentationEmail(
          from: {userBEmailAddress},
          to: {userAEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.replyAll,
          isSender: false,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });

      test(
        'THEN user A click reply to list, generateRecipientsEmailAddressForComposer\n'
        'SHOULD return email address in mailto of List-Post to reply\n',
      () {
        final expectedResult = Tuple3([replyToListEmailAddress], [], []);

        final emailToReplyToList = PresentationEmail(
          from: {userBEmailAddress},
          replyTo: {replyToEmailAddress},
          to: {userAEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress},
        );

        final result = emailToReplyToList.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.replyToList,
          isSender: false,
          listPost: '<mailto:${replyToListEmailAddress.emailAddress}>',
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });
    });

    group('Given user A is the sender AND sends an email to user B + user E, cc to user C, bcc to user D THEN user B clicks forward', () {
      test('generateRecipientsEmailAddressForComposer SHOULD return user user B email + user E email to reply, user C email to cc, user D email to bcc', () {
        final expectedResult = Tuple3([userBEmailAddress, userEEmailAddress], <EmailAddress>[userCEmailAddress], <EmailAddress>[userDEmailAddress]);

        final emailToReply = PresentationEmail(
          from: {userAEmailAddress},
          to: {userBEmailAddress, userEEmailAddress},
          cc: {userCEmailAddress},
          bcc: {userDEmailAddress}
        );

        final result = emailToReply.generateRecipientsEmailAddressForComposer(
          emailActionType: EmailActionType.forward,
          isSender: false,
        );

        expect(result.value1, containsAll(expectedResult.value1));
        expect(result.value2, containsAll(expectedResult.value2));
        expect(result.value3, containsAll(expectedResult.value3));
      });
    });
  });
}