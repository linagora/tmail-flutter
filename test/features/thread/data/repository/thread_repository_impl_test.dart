import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadDataSource>(),
  MockSpec<StateDataSource>(),
])
void main() {
  late MockThreadDataSource threadDataSource;
  late MockStateDataSource stateDataSource;
  late ThreadRepositoryImpl threadRepository;

  setUp(() {
    threadDataSource = MockThreadDataSource();
    stateDataSource = MockStateDataSource();
    threadRepository = ThreadRepositoryImpl(
      {
        DataSourceType.network: threadDataSource,
        DataSourceType.local: threadDataSource,
      },
      stateDataSource,
    );
  });

  tearDown(() {
    reset(threadDataSource);
    reset(stateDataSource);
  });

  group('getAllEmail:', () {
    test('when local cache is empty should fetch from network', () async {
      // Arrange
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value([]));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(null));

      final networkEmails = List.generate(
        20, 
        (index) => Email(id: EmailId(Id('network_$index')))
      );
      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
          emailList: networkEmails,
          state: State('network_state'))));

      // Act
      final responses = await threadRepository
        .getAllEmail(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        )
        .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, networkEmails);
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
      ));
      verify(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test('when local cache has fewer than default limit emails '
         'and no need getLatestChanges '
         'should fetch from network '
         'and state should not be saved',
        () async {
      // Arrange
      final localEmails =
          List.generate(5, (index) => Email(id: EmailId(Id('local_$index'))));
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
        .thenAnswer((_) => Future.value(State('local_state')));

      final networkEmails = List.generate(
        ThreadConstants.defaultLimit.value as int,
        (index) => Email(id: EmailId(Id('network_$index')))
      );
      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
          emailList: networkEmails,
          state: State('network_state'))));

      // Act
      final responses = await threadRepository
        .getAllEmail(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          getLatestChanges: false,
        )
        .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, networkEmails);
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
      ));
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test('when local cache has sufficient emails '
         'and no need getLatestChanges '
         'should not fetch from network ',
        () async {
      // Arrange
      final localEmails = List.generate(
        ThreadConstants.defaultLimit.value as int,
        (index) => Email(id: EmailId(Id('local_$index')))
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
        .thenAnswer((_) => Future.value(State('local_state')));

      // Act
      final responses = await threadRepository
        .getAllEmail(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          getLatestChanges: false
        )
        .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, localEmails);
      verifyNever(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      ));
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test('when local cache has insufficient emails '
         'and no need getLatestChanges '
         'should fetch from network '
         'and state should not be saved',
        () async {
      // Arrange
      final localEmails = List.generate(
        5,
        (index) => Email(id: EmailId(Id('local_$index')))
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
        .thenAnswer((_) => Future.value(State('local_state')));

      final networkEmails = List.generate(
        ThreadConstants.defaultLimit.value as int,
        (index) => Email(id: EmailId(Id('network_$index')))
      );
      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
          emailList: networkEmails,
          state: State('network_state'))));

      // Act
      final responses = await threadRepository
        .getAllEmail(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          getLatestChanges: false
        )
        .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, networkEmails);
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
      ));
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    // why need to fetch first page if filter option is not "all"?
    // try to cache all data of this folder, not miss any messages
    test('when filter option is not "all" '
         'and no need getLatestChanges '
         'should fetch first page of all messages for this folder', () async {
      // Arrange
      final mailboxId = MailboxId(Id('mailbox_id'));
      final localEmails = List.generate(
        10,
        (index) => Email(id: EmailId(Id('local_$index')))
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
        .thenAnswer((_) => Future.value(State('local_state')));

      final networkEmails = List.generate(
        ThreadConstants.defaultLimit.value as int,
        (index) => Email(id: EmailId(Id('network_$index')))
      );
      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
          emailList: networkEmails,
          state: State('network_state'))));

      // Act
      final responses = await threadRepository
        .getAllEmail(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          emailFilter: EmailFilter(filterOption: FilterMessageOption.unread, mailboxId: mailboxId),
          getLatestChanges: false,
        )
        .toList();

      // Assert
      expect(responses.length, 2);
      verify(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        filter: anyNamed('filter'),
      )).called(2); // Once for initial fetch, once for first page
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
      )).called(2);
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test('when local has mail in cache and getLatestChanges is true should synchronize cache', () async {
      // Arrange
      final localEmails = List.generate(
        ThreadConstants.defaultLimit.value as int,
        (index) => Email(id: EmailId(Id('local_$index'))));
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      final changedEmails =
          List.generate(5, (index) => Email(id: EmailId(Id('changed_$index'))));
      when(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).thenAnswer((_) => Future.value(EmailChangeResponse(
          hasMoreChanges: false,
          created: changedEmails,
          newStateEmail: State('new_state'))));

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            getLatestChanges: true,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      verifyNever(threadDataSource.getAllEmail(any, any));
      verify(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      ));
      verify(threadDataSource.update(
        any,
        any,
        created: changedEmails,
      ));
      verify(stateDataSource.saveState(any, any, any));
    });

    test('when getChanges has more changes should fetch all changes', () async {
      // Arrange
      final localEmails = List.generate(
          ThreadConstants.defaultLimit.value as int,
          (index) => Email(id: EmailId(Id('local_$index'))));
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      final firstChanges = List.generate(
          5, (index) => Email(id: EmailId(Id('change1_$index'))));
      final secondChanges = List.generate(
          5, (index) => Email(id: EmailId(Id('change2_$index'))));

      var callCount = 0;
      when(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).thenAnswer((_) {
        callCount++;
        if (callCount == 1) {
          return Future.value(EmailChangeResponse(
            hasMoreChanges: true,
            created: firstChanges,
            newStateChanges: State('intermediate_state'),
            newStateEmail: State('intermediate_state_email'),
          ));
        } else {
          return Future.value(EmailChangeResponse(
            hasMoreChanges: false,
            created: secondChanges,
            newStateChanges: State('final_state'),
            newStateEmail: State('final_state_email'),
          ));
        }
      });

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            getLatestChanges: true,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      verify(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).called(2);
      verify(threadDataSource.update(
        any,
        any,
        created: anyNamed('created'),
      ));
      verify(stateDataSource.saveState(any, any, any));
    });

    test('when local has mail in cache but network errors '
         'should return email from local', () async {
      // Arrange
      final localEmails = List.generate(
          ThreadConstants.defaultLimit.value as int,
          (index) => Email(id: EmailId(Id('local_$index'))));
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenThrow(Exception('Network error'));

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            getLatestChanges: false,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, localEmails);
      verifyNever(threadDataSource.getAllEmail(
        any, 
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      ));
      verifyNever(threadDataSource.update(
        any,
        any,
        created: anyNamed('created'),
      ));
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });
  });

  group('The functions regard to updateEmailCache:', () {
    test(
        'when local cache is empty should fetch from network '
        'and network has mail not found '
        'should delete mail not found in cache', () async {
      // Arrange
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value([]));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(null));

      final networkEmails = List.generate(
        ThreadConstants.defaultLimit.value.toInt(),
            (index) => Email(id: EmailId(Id('network_$index'))),
      );

      final networkNotFoundEmailIds = List.generate(
        5,
            (index) => EmailId(Id('network_not_found_$index')),
      );

      when(threadDataSource.getAllEmail(
        any,
        any,
        position: anyNamed('position'),
        filter: anyNamed('filter'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
            emailList: networkEmails,
            notFoundEmailIds: networkNotFoundEmailIds,
            state: State('network_state'),
          )));

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, networkEmails);
      expect(responses[0].notFoundEmailIds, networkNotFoundEmailIds);
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
        destroyed: networkNotFoundEmailIds,
      ));
      verify(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test(
        'when filter option is not "all" '
        'and no need getLatestChanges '
        'then fetch first page of all messages for this folder '
        'and network has mail not found '
        'should delete mail not found in cache', () async {
      // Arrange
      final mailboxId = MailboxId(Id('mailbox_id'));
      final localEmails = List.generate(
        10,
        (index) => Email(id: EmailId(Id('local_$index'))),
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      final networkEmails = List.generate(
        ThreadConstants.defaultLimit.value.toInt(),
        (index) => Email(id: EmailId(Id('network_$index'))),
      );

      final networkNotFoundEmailIds = List.generate(
        5,
        (index) => EmailId(Id('network_not_found_$index')),
      );

      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
            emailList: networkEmails,
            notFoundEmailIds: networkNotFoundEmailIds,
            state: State('network_state'),
          )));

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            emailFilter: EmailFilter(
              filterOption: FilterMessageOption.unread,
              mailboxId: mailboxId,
            ),
            getLatestChanges: false,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      verify(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        filter: anyNamed('filter'),
      )).called(2); // Once for initial fetch, once for first page
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
        destroyed: networkNotFoundEmailIds,
      )).called(2);
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test(
        'when local has mail in cache and getLatestChanges is true '
        'and email change has destroyed mail '
        'should delete destroyed mail in cache', () async {
      // Arrange
      final localEmails = List.generate(
        ThreadConstants.defaultLimit.value.toInt(),
        (index) => Email(id: EmailId(Id('local_$index'))),
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      final changedEmails = List.generate(
        5,
        (index) => Email(id: EmailId(Id('changed_$index'))),
      );

      final destroyedEmailIds = List.generate(
        5,
        (index) => EmailId(Id('destroyed_mail_$index')),
      );
      when(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).thenAnswer((_) => Future.value(EmailChangeResponse(
          hasMoreChanges: false,
          created: changedEmails,
          destroyed: destroyedEmailIds,
          newStateEmail: State('new_state'))));

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            getLatestChanges: true,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      verifyNever(threadDataSource.getAllEmail(any, any));
      verify(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      ));
      verify(threadDataSource.update(
        any,
        any,
        created: changedEmails,
        destroyed: destroyedEmailIds,
      ));
      verify(stateDataSource.saveState(any, any, any));
    });

    test(
        'when getChanges has more changes should fetch all changes '
        'and first email change has destroyed mail '
        'should delete destroyed mail in cache', () async {
      // Arrange
      final localEmails = List.generate(
        ThreadConstants.defaultLimit.value.toInt(),
        (index) => Email(id: EmailId(Id('local_$index'))),
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      final firstChanges = List.generate(
        5,
        (index) => Email(id: EmailId(Id('change1_$index'))),
      );
      final secondChanges = List.generate(
        5,
        (index) => Email(id: EmailId(Id('change2_$index'))),
      );

      var callCount = 0;

      final firstDestroyedEmailIds = List.generate(
        5,
        (index) => EmailId(Id('destroyed_mail_$index')),
      );

      when(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).thenAnswer((_) {
        callCount++;
        if (callCount == 1) {
          return Future.value(EmailChangeResponse(
            hasMoreChanges: true,
            created: firstChanges,
            destroyed: firstDestroyedEmailIds,
            newStateChanges: State('intermediate_state'),
            newStateEmail: State('intermediate_state_email'),
          ));
        } else {
          return Future.value(EmailChangeResponse(
            hasMoreChanges: false,
            created: secondChanges,
            newStateChanges: State('final_state'),
            newStateEmail: State('final_state_email'),
          ));
        }
      });

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            getLatestChanges: true,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      verify(threadDataSource.getChanges(
        any,
        any,
        any,
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      )).called(2);
      verify(threadDataSource.update(
        any,
        any,
        created: anyNamed('created'),
        destroyed: anyNamed('destroyed'),
      ));
      verify(stateDataSource.saveState(any, any, any));
    });

    test(
        'when local has mail in cache but network errors '
        'and return email from local '
        'should not call update email cache', () async {
      // Arrange
      final localEmails = List.generate(
        ThreadConstants.defaultLimit.value.toInt(),
        (index) => Email(id: EmailId(Id('local_$index'))),
      );
      when(threadDataSource.getAllEmailCache(
        any,
        any,
        filterOption: anyNamed('filterOption'),
        inMailboxId: anyNamed('inMailboxId'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) => Future.value(localEmails));

      when(stateDataSource.getState(any, any, any))
          .thenAnswer((_) => Future.value(State('local_state')));

      when(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      )).thenThrow(Exception('Network error'));

      // Act
      final responses = await threadRepository
          .getAllEmail(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            getLatestChanges: false,
          )
          .toList();

      // Assert
      expect(responses.length, 2);
      expect(responses[0].emailList, localEmails);
      verifyNever(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      ));
      verifyNever(threadDataSource.update(
        any,
        any,
        created: anyNamed('created'),
        updated: anyNamed('updated'),
        destroyed: anyNamed('created'),
      ));
      verifyNever(stateDataSource.saveState(
        any,
        any,
        any,
      ));
    });

    test(
        'when fetching more emails '
        'and network has mails and not found mails '
        'should delete mail not found in cache', () async {
      // Arrange
      final networkEmails = List.generate(
        ThreadConstants.defaultLimit.value.toInt(),
            (index) => Email(id: EmailId(Id('network_$index'))),
      );

      final networkNotFoundEmailIds = List.generate(
        5,
            (index) => EmailId(Id('network_not_found_$index')),
      );

      when(threadDataSource.getAllEmail(
        any,
        any,
        position: anyNamed('position'),
        filter: anyNamed('filter'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        properties: anyNamed('properties'),
      )).thenAnswer((_) => Future.value(EmailsResponse(
        emailList: networkEmails,
        notFoundEmailIds: networkNotFoundEmailIds,
        state: State('network_state'),
      )));

      // Act
      final responses = await threadRepository
          .loadMoreEmails(GetEmailRequest(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
          ))
          .toList();

      // Assert
      expect(responses.length, 1);
      expect(responses[0].emailList, networkEmails);
      expect(responses[0].notFoundEmailIds, networkNotFoundEmailIds);
      verify(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      ));
      verify(threadDataSource.update(
        any,
        any,
        created: networkEmails,
        destroyed: networkNotFoundEmailIds,
      ));
    });

    test(
        'when fetching more emails and network errors '
        'should not call update mail cache', () async {
      // Arrange
      when(threadDataSource.getAllEmail(
        any,
        any,
        position: anyNamed('position'),
        filter: anyNamed('filter'),
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        properties: anyNamed('properties'),
      )).thenThrow(Exception('Network error'));

      // Assert
      expectLater(
        () => threadRepository
            .loadMoreEmails(GetEmailRequest(
              SessionFixtures.aliceSession,
              AccountFixtures.aliceAccountId,
            ))
            .toList(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'description', contains('Network error'))),
      );
      verifyNever(threadDataSource.getAllEmail(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      ));
      verifyNever(threadDataSource.update(
        any,
        any,
        created: anyNamed('created'),
        updated: anyNamed('updated'),
        destroyed: anyNamed('created'),
      ));
    });
  });
}
