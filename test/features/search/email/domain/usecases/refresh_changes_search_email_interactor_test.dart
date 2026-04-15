import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';
import 'refresh_changes_search_email_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadRepository>()])
void main() {
  final threadRepository = MockThreadRepository();
  final interactor = RefreshChangesSearchEmailInteractor(threadRepository);

  group('refresh changes search email interactor test:',
    () => _refreshChangesSearchEmailTests(threadRepository, interactor));
}

void _stubSearchEmails(
  MockThreadRepository repo, {
  List<SearchEmail>? returns,
  Object? throws,
}) {
  final stub = when(repo.searchEmails(
    any,
    any,
    limit: anyNamed('limit'),
    sort: anyNamed('sort'),
    filter: anyNamed('filter'),
    collapseThreads: anyNamed('collapseThreads'),
    properties: anyNamed('properties'),
  ));
  if (throws != null) {
    stub.thenThrow(throws);
  } else {
    stub.thenAnswer((_) async => returns ?? []);
  }
}

void _refreshChangesSearchEmailTests(
  MockThreadRepository threadRepository,
  RefreshChangesSearchEmailInteractor interactor,
) {
  test(
    'should return list of presentation emails '
    'when threadRepository.searchEmails returns list of emails',
    () {
      final searchEmail = SearchEmail(
        searchSnippetSubject: 'searchSnippetSubject',
        searchSnippetPreview: 'searchSnippetPreview',
      );
      _stubSearchEmails(threadRepository, returns: [searchEmail]);

      final result = interactor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        filter: EmailFilterCondition(text: 'test'),
      );

      expect(
        result,
        emitsInOrder([
          Right(RefreshingChangeSearchEmailState()),
          Right(RefreshChangesSearchEmailSuccess([searchEmail.toPresentationEmail(
            searchSnippetSubject: searchEmail.searchSnippetSubject,
            searchSnippetPreview: searchEmail.searchSnippetPreview,
          )])),
        ])
      );
    },
  );

  test(
    'should return failure '
    'when threadRepository.searchEmails throw exception',
    () {
      final exception = Exception();
      _stubSearchEmails(threadRepository, throws: exception);

      final result = interactor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        filter: EmailFilterCondition(text: 'test'),
      );

      expect(
        result,
        emitsInOrder([
          Right(RefreshingChangeSearchEmailState()),
          Left(RefreshChangesSearchEmailFailure(exception)),
        ])
      );
    },
  );
}
