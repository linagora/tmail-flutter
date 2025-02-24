import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'search_email_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadRepository>()])
void main() {
  final threadRepository = MockThreadRepository();
  final searchEmailInteractor = SearchEmailInteractor(threadRepository);

  group('search email interactor test:', () {
    test(
      'should return list of presentation emails '
      'when threadRepository.searchEmails returns list of emails with search snippets',
    () {
      // arrange
      final searchEmail = SearchEmail(
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
      final result = searchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        filter: EmailFilterCondition(text: 'test'),
      );
      
      // assert
      expect(
        result,
        emitsInOrder([
          Right(SearchingState()),
          Right(SearchEmailSuccess(
            [searchEmail.toPresentationEmail(
              searchSnippetSubject: searchEmail.searchSnippetSubject,
              searchSnippetPreview: searchEmail.searchSnippetPreview,
            )],
          ))
        ]),
      );
    });

    test(
      'should return list of presentation emails '
      'when threadRepository.searchEmails returns list of emails without search snippets',
    () {
      // arrange
      final searchEmail = SearchEmail(
        searchSnippetSubject: null,
        searchSnippetPreview: null,
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
      final result = searchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        filter: EmailFilterCondition(text: 'test'),
      );
      
      // assert
      expect(
        result,
        emitsInOrder([
          Right(SearchingState()),
          Right(SearchEmailSuccess([searchEmail.toPresentationEmail()]))
        ]),
      );
    });

    test(
      'should return Failure when threadRepository.searchEmails returns Failure',
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
        final result = searchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          filter: EmailFilterCondition(text: 'test'),
        ).asBroadcastStream();
        
        // assert
        final firstState = await result.first;
        final lastState = await result.last;
        expect(firstState, Right(SearchingState()));
        expect(
          lastState.fold((failure) {
            return failure is SearchEmailFailure
              && failure.exception == exception
              && failure.onRetry is Stream<Either<Failure, Success>>;
          }, (success) => false),
          true,
        );
      },
    );
  });
}