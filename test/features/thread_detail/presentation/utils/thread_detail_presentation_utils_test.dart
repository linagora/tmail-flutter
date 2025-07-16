import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

void main() {
  group('ThreadDetailPresentationUtils', () {
    group('getEmailIdsToLoad', () {
      test(
        'should return empty list '
        'when emailIds is empty',
      () {
        // arrange
        final emailIds = <EmailId>[];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
        );
        
        // assert
        expect(result, isEmpty);
      });

      test(
        'should return all email ids in emailIds '
        'when isFirstLoad is true '
        'and emailIds contains equal to or less than 3 email ids',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
        );
        
        // assert
        expect(result, equals(emailIds));
      });

      test(
        'should return first two emails and last email '
        'when isFirstLoad is true '
        'and emailIds contains more than 3 email ids '
        'and selectedEmailId is not null ',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
        );
        
        // assert
        expect(
          result,
          equals([EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('5'))]),
        );
      });

      test(
        'should return first two emails and last email '
        'when isFirstLoad is true '
        'and emailIds contains more than 3 email ids '
        'and selectedEmailId is not inside emailIds',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
          selectedEmailId: EmailId(Id('6')),
        );
        
        // assert
        expect(
          result,
          equals([EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('5'))]),
        );
      });

      test(
        'should return first two emails and last email '
        'when isFirstLoad is true '
        'and emailIds contains more than 3 email ids '
        'and selectedEmailId is first element of emailIds',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
          selectedEmailId: emailIds.first,
        );
        
        // assert
        expect(
          result,
          equals([EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('5'))]),
        );
      });

      test(
        'should return first two emails and last email '
        'when isFirstLoad is true '
        'and emailIds contains more than 3 email ids '
        'and selectedEmailId is last element of emailIds',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
          selectedEmailId: emailIds.last,
        );
        
        // assert
        expect(
          result,
          equals([EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('5'))]),
        );
      });

      test(
        'should return first two emails and last email '
        'when isFirstLoad is true '
        'and emailIds contains more than 3 email ids '
        'and selectedEmailId is second element of emailIds',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
          selectedEmailId: emailIds.elementAt(1),
        );
        
        // assert
        expect(
          result,
          equals([EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('5'))]),
        );
      });

      test(
        'should return first, last and selected email '
        'when emailIds contains more than 3 email ids '
        'and isFirstLoad is true '
        'and selectedEmailId is inside emailIds '
        'and selectedEmailId is not first, last or second element of emailIds',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        final selectedEmail = EmailId(Id('3'));
        
        // act
        final result = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
          emailIds,
          selectedEmailId: selectedEmail,
        );
        
        // assert
        expect(
          result,
          equals([emailIds.first, selectedEmail, emailIds.last]),
        );
      });

      test(
        'should return all emails '
        'when emailIds contains more than 3 email ids '
        'and isFirstLoad is false '
        'and loadEmailsAfterSelectedEmail is true '
        'and emailsIds.length is less than defaultLoadSize',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getLoadMoreEmailIds(
          emailIds,
          loadEmailsAfterSelectedEmail: true,
        );
        
        // assert
        expect(
          result,
          equals(emailIds),
        );
      });

      test(
        'should return first defaultLoadSize (20) emails '
        'when emailIds contains more than 3 email ids '
        'and isFirstLoad is false '
        'and loadEmailsAfterSelectedEmail is true '
        'and emailsIds.length is more than defaultLoadSize',
      () {
        // arrange
        final emailIds = List.generate(30, (i) => EmailId(Id('$i')));
        
        // act
        final result = ThreadDetailPresentationUtils.getLoadMoreEmailIds(
          emailIds,
          loadEmailsAfterSelectedEmail: true,
        );
        
        // assert
        expect(
          result,
          equals(emailIds.sublist(
            0,
            ThreadDetailPresentationUtils.defaultLoadSize,
          )),
        );
      });
      
      test(
        'should return all emails '
        'when emailIds contains more than 3 email ids '
        'and isFirstLoad is false '
        'and loadEmailsAfterSelectedEmail is false '
        'and emailsIds.length is less than defaultLoadSize',
      () {
        // arrange
        final emailIds = [
          EmailId(Id('1')),
          EmailId(Id('2')),
          EmailId(Id('3')),
          EmailId(Id('4')),
          EmailId(Id('5')),
        ];
        
        // act
        final result = ThreadDetailPresentationUtils.getLoadMoreEmailIds(
          emailIds,
          loadEmailsAfterSelectedEmail: false,
        );
        
        // assert
        expect(
          result,
          equals(emailIds),
        );
      });

      test(
        'should return last defaultLoadSize (20) emails '
        'when emailIds contains more than 3 email ids '
        'and isFirstLoad is false '
        'and loadEmailsAfterSelectedEmail is false '
        'and emailsIds.length is more than defaultLoadSize',
      () {
        // arrange
        final emailIds = List.generate(30, (i) => EmailId(Id('$i')));
        
        // act
        final result = ThreadDetailPresentationUtils.getLoadMoreEmailIds(
          emailIds,
          loadEmailsAfterSelectedEmail: false,
        );
        
        // assert
        expect(
          result,
          equals(emailIds.sublist(
            emailIds.length - ThreadDetailPresentationUtils.defaultLoadSize,
            emailIds.length,
          )),
        );
      });
    });

    group('refreshEmailIds', () {
      test('should return original emails when no created or destroyed', () {
        final original = [EmailId(Id('1')), EmailId(Id('2'))];
        expect(
          ThreadDetailPresentationUtils.refreshEmailIds(
            original: original,
            created: [],
            destroyed: [],
          ),
          original,
        );
      });

      test('should remove destroyed emails from original', () {
        final original = [EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('3'))];
        final destroyed = [EmailId(Id('2'))];
        expect(
          ThreadDetailPresentationUtils.refreshEmailIds(
            original: original,
            created: [],
            destroyed: destroyed,
          ),
          [EmailId(Id('1')), EmailId(Id('3'))],
        );
      });

      test('should add created emails to original', () {
        final original = [EmailId(Id('1'))];
        final created = [EmailId(Id('2')), EmailId(Id('3'))];
        expect(
          ThreadDetailPresentationUtils.refreshEmailIds(
            original: original,
            created: created,
            destroyed: [],
          ),
          [EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('3'))],
        );
      });

      test('should combine created and destroyed operations', () {
        final original = [EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('3'))];
        final created = [EmailId(Id('4'))];
        final destroyed = [EmailId(Id('2'))];
        expect(
          ThreadDetailPresentationUtils.refreshEmailIds(
            original: original,
            created: created,
            destroyed: destroyed,
          ),
          [EmailId(Id('1')), EmailId(Id('3')), EmailId(Id('4'))],
        );
      });

      test('should ignore destroyed emails not present in original', () {
        final original = [EmailId(Id('1'))];
        final destroyed = [EmailId(Id('99'))];
        expect(
          ThreadDetailPresentationUtils.refreshEmailIds(
            original: original,
            created: [],
            destroyed: destroyed,
          ),
          original,
        );
      });

      test('should handle duplicate created emails', () {
        final original = [EmailId(Id('1'))];
        final created = [EmailId(Id('2')), EmailId(Id('2'))];
        expect(
          ThreadDetailPresentationUtils.refreshEmailIds(
            original: original,
            created: created,
            destroyed: [],
          ),
          [EmailId(Id('1')), EmailId(Id('2')), EmailId(Id('2'))],
        );
      });
    });

    group('refreshPresentationEmails', () {
      final email1 = PresentationEmail(id: EmailId(Id('1')), keywords: {}, mailboxIds: {});
      final email2 = PresentationEmail(id: EmailId(Id('2')), keywords: {}, mailboxIds: {});
      final email3 = PresentationEmail(id: EmailId(Id('3')), keywords: {}, mailboxIds: {});
      
      final updatedEmail2 = PresentationEmail(
        id: EmailId(Id('2')),
        keywords: {KeyWordIdentifier('updated'): true},
        mailboxIds: {MailboxId(Id('mailbox')): true}
      );

      test('should combine non-destroyed originals with updates and created emails', () {
        final result = ThreadDetailPresentationUtils.refreshPresentationEmails(
          original: [email1, email2],
          created: [email3],
          updated: [updatedEmail2],
          destroyed: [EmailId(Id('1'))],
        );

        expect(result, [
          email2.copyWith(
            keywords: updatedEmail2.keywords,
            mailboxIds: updatedEmail2.mailboxIds,
          ),
          email3,
        ]);
      });

      test('should handle empty destroyed and updated lists', () {
        final result = ThreadDetailPresentationUtils.refreshPresentationEmails(
          original: [email1],
          created: [email2],
          updated: [],
          destroyed: [],
        );

        expect(result, [email1, email2]);
      });

      test('should exclude all destroyed emails', () {
        final result = ThreadDetailPresentationUtils.refreshPresentationEmails(
          original: [email1, email2],
          created: [email3],
          updated: [],
          destroyed: [EmailId(Id('1')), EmailId(Id('2'))],
        );

        expect(result, [email3]);
      });

      test('should apply updates to remaining original emails', () {
        final result = ThreadDetailPresentationUtils.refreshPresentationEmails(
          original: [email1, email2],
          created: [],
          updated: [updatedEmail2],
          destroyed: [],
        );

        expect(result, [
          email1,
          updatedEmail2,
        ]);
      });

      test('should handle empty original list', () {
        final result = ThreadDetailPresentationUtils.refreshPresentationEmails(
          original: [],
          created: [email1, email2],
          updated: [],
          destroyed: [],
        );

        expect(result, [email1, email2]);
      });

      test('should handle emails being both destroyed and updated', () {
        final result = ThreadDetailPresentationUtils.refreshPresentationEmails(
          original: [email1],
          created: [],
          updated: [email1.copyWith(keywords: {KeyWordIdentifier('test'): true})],
          destroyed: [EmailId(Id('1'))],
        );

        expect(result, isEmpty);
      });
    });
  });
}
