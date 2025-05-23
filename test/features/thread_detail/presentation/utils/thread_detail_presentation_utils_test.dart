import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
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
  });
}
