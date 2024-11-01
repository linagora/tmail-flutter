import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'quick_search_email_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadRepository>()])
void main() {
  final threadRepository = MockThreadRepository();
  final quickSearchEmailInteractor = QuickSearchEmailInteractor(threadRepository);

  group('quick search email interactor test:', () {
    test(
      'should return list of presentation emails '
      'when threadRepository.searchEmails returns list of emails',
    () async {
      // arrange
      final searchEmail = SearchEmail(
        id: EmailId(Id('someId')),
        searchSnippetSubject: 'searchSnippetSubject',
        searchSnippetPreview: 'searchSnippetPreview',
      );
      when(
        threadRepository.searchEmails(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
        ),
      ).thenAnswer((_) async => [searchEmail]);
      
      // act
      final result = await quickSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        filter: EmailFilterCondition(text: 'test'),
      );
      
      // assert
      expect(
        result,
        equals(Right(QuickSearchEmailSuccess([searchEmail.toPresentationEmail(
          searchSnippetSubject: searchEmail.searchSnippetSubject,
          searchSnippetPreview: searchEmail.searchSnippetPreview,
        )]))),
      );
    });

    test(
      'should return failure '
      'when threadRepository.searchEmails throws exception',
    () async {
      // arrange
      final exception = Exception();
      when(
        threadRepository.searchEmails(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
        ),
      ).thenThrow(exception);
      
      // act
      final result = await quickSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        filter: EmailFilterCondition(text: 'test'),
      );
      
      // assert
      expect(
        result,
        equals(Left(QuickSearchEmailFailure(exception))),
      );
    });
  });
}