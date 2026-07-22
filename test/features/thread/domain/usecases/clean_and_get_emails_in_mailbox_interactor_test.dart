import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/clean_and_get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/clean_and_get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'clean_and_get_emails_in_mailbox_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadRepository>(),
  MockSpec<GetEmailsInMailboxInteractor>(),
])
void main() {
  late MockThreadRepository threadRepository;
  late MockGetEmailsInMailboxInteractor getEmailsInMailboxInteractor;
  late CleanAndGetEmailsInMailboxInteractor interactor;

  setUp(() {
    threadRepository = MockThreadRepository();
    getEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
    interactor = CleanAndGetEmailsInMailboxInteractor(
      threadRepository,
      getEmailsInMailboxInteractor,
    );
  });

  void stubGetEmailsInMailbox(Stream<Either<Failure, Success>> stream) {
    when(getEmailsInMailboxInteractor.execute(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      limit: anyNamed('limit'),
      sort: anyNamed('sort'),
      emailFilter: anyNamed('emailFilter'),
      propertiesCreated: anyNamed('propertiesCreated'),
      propertiesUpdated: anyNamed('propertiesUpdated'),
      getLatestChanges: true,
      useCache: true,
    )).thenAnswer((_) => stream);
  }

  Future<List<Either<Failure, Success>>> executeInteractor() => interactor
      .execute(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId)
      .toList();

  final innerSuccess = Right<Failure, Success>(GetAllEmailSuccess(
    emailList: [EmailFixtures.email1.toPresentationEmail()],
    currentEmailState: jmap.State('s1'),
  ));

  group('[CleanAndGetEmailsInMailboxInteractor]', () {
    test('Should clear the cache then forward the states of the delegated '
        'interactor WHEN it completes normally', () async {
      stubGetEmailsInMailbox(Stream.fromIterable([innerSuccess]));

      final states = await executeInteractor();

      verify(threadRepository.clearEmailCacheAndStateCache()).called(1);
      expect(states.first, Right<Failure, Success>(CleanAndGetAllEmailLoading()));
      expect(states.contains(innerSuccess), isTrue);
      expect(states.whereType<Left>(), isEmpty);
    });

    test('Should clear the cache before delegating and forward every query '
        'parameter to the delegated interactor', () async {
      final sort = <EmailComparator>{
        EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false),
      };
      final emailFilter = EmailFilter(
        filter: EmailFilterCondition(inMailbox: MailboxFixtures.inboxMailbox.id),
        mailboxId: MailboxFixtures.inboxMailbox.id,
      );

      when(getEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        getLatestChanges: false,
        useCache: false,
      )).thenAnswer((_) => Stream.fromIterable([innerSuccess]));

      final states = await interactor
          .execute(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            limit: UnsignedInt(20),
            sort: sort,
            emailFilter: emailFilter,
            propertiesCreated: ThreadConstants.propertiesDefault,
            propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
            getLatestChanges: false,
            useCache: false,
          )
          .toList();

      expect(states, [
        Right<Failure, Success>(CleanAndGetAllEmailLoading()),
        innerSuccess,
      ]);

      // The cache has to be dropped before the delegate refills it, otherwise
      // the reload would be served from the data this interactor is clearing.
      verifyInOrder([
        threadRepository.clearEmailCacheAndStateCache(),
        getEmailsInMailboxInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: UnsignedInt(20),
          sort: sort,
          emailFilter: emailFilter,
          propertiesCreated: ThreadConstants.propertiesDefault,
          propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
          getLatestChanges: false,
          useCache: false,
        ),
      ]);
    });

    test('Should emit CleanAndGetAllEmailFailure '
        'WHEN the delegated interactor stream raises an error', () async {
      final exception = StateError('delegated stream broke');

      stubGetEmailsInMailbox(() async* {
        yield innerSuccess;
        throw exception;
      }());

      final states = await executeInteractor();

      expect(states.contains(innerSuccess), isTrue);

      final failure = states
          .whereType<Left>()
          .map((state) => state.value)
          .whereType<CleanAndGetAllEmailFailure>()
          .single;

      expect(failure.exception, exception);
    });

    test('Should emit CleanAndGetAllEmailFailure and never delegate '
        'WHEN clearing the cache throws', () async {
      final exception = StateError('cache clear failed');

      when(threadRepository.clearEmailCacheAndStateCache())
          .thenThrow(exception);

      final states = await executeInteractor();

      final failure = states
          .whereType<Left>()
          .map((state) => state.value)
          .whereType<CleanAndGetAllEmailFailure>()
          .single;

      expect(failure.exception, exception);
      verifyNever(getEmailsInMailboxInteractor.execute(any, any));
    });
  });
}
