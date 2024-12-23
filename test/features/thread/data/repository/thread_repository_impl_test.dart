import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDataSource>(),
  MockSpec<StateDataSource>(),
])
void main() {
  final threadDataSource = MockThreadDataSource();
  final stateDataSource = MockStateDataSource();
  final threadRepository = ThreadRepositoryImpl(
    {
      DataSourceType.network: threadDataSource,
      DataSourceType.local: threadDataSource,
    },
    stateDataSource,
  );

  group('thread repository impl test:', () {
    test(
      'should not call threadDatasource.getChanges '
      'when getAllEmail is called '
      'and getLatestChanges is false',
    () async {
      // arrange
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer(
        (_) => Future.value(List.generate(30, (index) => Email(id: EmailId(Id('$index'))))),
      );
      when(stateDataSource.getState(
        any,
        any,
        any,
      )).thenAnswer((_) => Future.value(State('some-state')));
      when(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).thenAnswer(
        (_) => Future.value(EmailChangeResponse(hasMoreChanges: false)),
      );
      
      // act
      await threadRepository.getAllEmail(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        getLatestChanges: false,
      ).last;
      
      // assert
      verifyNever(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      ));
    });

    test(
      'should call threadDatasource.getChanges '
      'when getAllEmail is called '
      'and getLatestChanges is true',
    () async {
      // arrange
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer(
        (_) => Future.value(List.generate(30, (index) => Email(id: EmailId(Id('$index'))))),
      );
      when(stateDataSource.getState(
        any,
        any,
        any,
      )).thenAnswer((_) => Future.value(State('some-state')));
      when(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).thenAnswer(
        (_) => Future.value(EmailChangeResponse(hasMoreChanges: false)),
      );
      
      // act
      await threadRepository.getAllEmail(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        getLatestChanges: true,
      ).last;
      
      // assert
      verify(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      ));
    });
  });
}