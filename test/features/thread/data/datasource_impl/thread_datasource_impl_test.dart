import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

import 'thread_datasource_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadAPI>(),
  MockSpec<ThreadIsolateWorker>(),
  MockSpec<ExceptionThrower>(),
  MockSpec<Session>(),
  MockSpec<AccountId>(),
])
void main() {
  // Mirrors the hard iteration cap declared in ThreadDataSourceImpl. Kept in
  // sync manually since the production constant is private.
  const int maxIterations = 100;

  late MockThreadAPI threadAPI;
  late MockExceptionThrower exceptionThrower;
  late ThreadDataSourceImpl dataSource;
  final session = MockSession();
  final accountId = MockAccountId();

  List<Email> emails(String prefix, int count) =>
      List.generate(count, (i) => Email(id: EmailId(Id('${prefix}_$i'))));

  // Shared matcher for threadAPI.getChanges, reused by both stubbing and
  // verification so the long named-argument signature lives in one place.
  void stubGetChanges(Future<EmailChangeResponse> Function(Invocation) answer) {
    when(threadAPI.getChanges(any, any, any,
            propertiesCreated: anyNamed('propertiesCreated'),
            propertiesUpdated: anyNamed('propertiesUpdated')))
        .thenAnswer(answer);
  }

  VerificationResult verifyGetChanges() => verify(threadAPI.getChanges(any, any,
      any,
      propertiesCreated: anyNamed('propertiesCreated'),
      propertiesUpdated: anyNamed('propertiesUpdated')));

  Future<EmailChangeResponse?> drain() =>
      dataSource.getAllEmailChanges(session, accountId, State('initial'));

  // A page that claims more changes; [nextState] drives the progress guard
  // (a repeated value or null is what makes the drain stop).
  EmailChangeResponse moreChangesPage({State? nextState}) => EmailChangeResponse(
        hasMoreChanges: true,
        created: emails('p', 1),
        newStateChanges: nextState,
      );

  setUp(() {
    threadAPI = MockThreadAPI();
    exceptionThrower = MockExceptionThrower();
    dataSource = ThreadDataSourceImpl(
      threadAPI,
      MockThreadIsolateWorker(),
      exceptionThrower,
    );
  });

  group('ThreadDataSourceImpl::getAllEmailChanges bound logic:', () {
    test('drains a single page when the server reports no more changes',
        () async {
      stubGetChanges((_) async => EmailChangeResponse(
            hasMoreChanges: false,
            created: emails('single', 3),
            newStateChanges: State('s1'),
          ));

      final result = await drain();

      expect(result?.created?.length, 3);
      verifyGetChanges().called(1);
    });

    test('drains every page and unions results while the state advances',
        () async {
      var call = 0;
      stubGetChanges((_) async {
        call++;
        return EmailChangeResponse(
          hasMoreChanges: call < 3,
          created: emails('p$call', 2),
          newStateChanges: State('s$call'),
          newStateEmail: State('email_s$call'),
        );
      });

      final result = await drain();

      // 3 pages × 2 created = 6, and the last page's state wins.
      expect(result?.created?.length, 6);
      expect(result?.newStateChanges, State('s3'));
      expect(result?.newStateEmail, State('email_s3'));
      verifyGetChanges().called(3);
    });

    test('aborts when the state cursor stops advancing (repeats a value)',
        () async {
      // Advance once, then keep returning the same state with more=true.
      stubGetChanges((_) async => moreChangesPage(nextState: State('stuck')));

      final result = await drain();

      expect(result, isNotNull);
      // 1st call advances initial -> stuck; 2nd call returns stuck again
      // (== previous) so the progress guard breaks. No request storm.
      verifyGetChanges().called(2);
    });

    test('aborts when more changes are claimed but the next state is null',
        () async {
      stubGetChanges((_) async => moreChangesPage());

      final result = await drain();

      expect(result, isNotNull);
      verifyGetChanges().called(1);
    });

    test('stops at the hard iteration cap even when the state keeps advancing',
        () async {
      var call = 0;
      // Always advancing AND always more changes: the only thing that can stop
      // this is the hard cap.
      stubGetChanges((_) async {
        call++;
        return EmailChangeResponse(
          hasMoreChanges: true,
          created: emails('p$call', 1),
          newStateChanges: State('s$call'),
        );
      });

      await drain();

      verifyGetChanges().called(maxIterations);
    });

    test('routes API errors through the exception thrower', () async {
      final error = Exception('boom');
      when(threadAPI.getChanges(any, any, any,
              propertiesCreated: anyNamed('propertiesCreated'),
              propertiesUpdated: anyNamed('propertiesUpdated')))
          .thenThrow(error);

      await drain();

      verify(exceptionThrower.throwException(error, any)).called(1);
    });
  });
}
