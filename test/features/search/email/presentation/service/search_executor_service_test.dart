import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_execution_observer.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';
// Reuse the notifier test's generated mocks (workspace build_runner constraint).
import '../../domain/notifier/search_email_notifier_test.mocks.dart';

/// Records every observer callback so a test can assert the fan-out.
class _RecordingObserver implements SearchExecutionObserver {
  int newSearchStarted = 0;
  int loading = 0;
  final results = <SearchEmailResult>[];
  final freshFlags = <bool>[];
  final failures = <Object>[];

  @override
  void onNewSearchStarted() => newSearchStarted++;

  @override
  void onSearchLoading() => loading++;

  @override
  void onSearchResult(SearchEmailResult result, {required bool isFreshResult}) {
    results.add(result);
    freshFlags.add(isFreshResult);
  }

  @override
  void onSearchFailure(Object error) => failures.add(error);
}

void main() {
  late MockSearchEmailInteractor searchInteractor;
  late MockSearchMoreEmailInteractor searchMoreInteractor;
  late MockRefreshChangesSearchEmailInteractor refreshInteractor;
  late MockUrgentExceptionHandler urgentHandler;

  final email = PresentationEmail(
    id: EmailId(Id('email1')),
    receivedAt: UTCDate(DateTime.parse('2021-08-10T04:00:59Z')),
  );

  final context = SearchDispatchContext(
    session: SessionFixtures.aliceSession,
    accountId: AccountFixtures.aliceAccountId,
    properties: Properties({'id'}),
    collapseThreads: false,
    trashSpamMailboxIds: null,
  );

  void stubSearch(Stream<Either<Failure, Success>> Function(Invocation) answer) {
    when(searchInteractor.execute(
      any,
      any,
      limit: anyNamed('limit'),
      position: anyNamed('position'),
      sort: anyNamed('sort'),
      filter: anyNamed('filter'),
      properties: anyNamed('properties'),
      collapseThreads: anyNamed('collapseThreads'),
      needRefreshSearchState: anyNamed('needRefreshSearchState'),
    )).thenAnswer(answer);
  }

  SearchExecutorService makeService() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return SearchExecutorService(container);
  }

  /// A service with a single registered observer — the common arrangement.
  ({SearchExecutorService service, _RecordingObserver observer})
      registeredService() {
    final service = makeService();
    final observer = _RecordingObserver();
    service.register(observer);
    return (service: service, observer: observer);
  }

  setUp(() {
    searchInteractor = MockSearchEmailInteractor();
    searchMoreInteractor = MockSearchMoreEmailInteractor();
    refreshInteractor = MockRefreshChangesSearchEmailInteractor();
    urgentHandler = MockUrgentExceptionHandler();
    Get.put<SearchEmailInteractor>(searchInteractor);
    Get.put<SearchMoreEmailInteractor>(searchMoreInteractor);
    Get.put<RefreshChangesSearchEmailInteractor>(refreshInteractor);
    Get.put<UrgentExceptionHandler>(urgentHandler);
    when(urgentHandler.validateUrgentException(any)).thenReturn(false);
    stubSearch((_) => Stream.value(Right(SearchEmailSuccess([email]))));
  });

  tearDown(Get.reset);

  test('dispatching a new search resets observers then fans out the result',
      () async {
    final (:service, :observer) = registeredService();

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    expect(observer.newSearchStarted, 1);
    expect(observer.loading, greaterThanOrEqualTo(1));
    expect(observer.results.single.emails, [email]);
    expect(observer.freshFlags.last, isTrue);
    verify(searchInteractor.execute(
      any,
      any,
      limit: anyNamed('limit'),
      position: anyNamed('position'),
      sort: anyNamed('sort'),
      filter: anyNamed('filter'),
      properties: anyNamed('properties'),
      collapseThreads: anyNamed('collapseThreads'),
    )).called(1);
  });

  test('load-more does not reset observers and its result is not fresh',
      () async {
    final (:service, :observer) = registeredService();

    await service.dispatch(
      LoadMoreIntent(
        currentCount: 20,
        lastEmailDate: email.receivedAt,
        lastEmailId: email.id,
      ),
      context,
    );
    await pumpEventQueue();

    expect(observer.newSearchStarted, 0);
    expect(observer.freshFlags, isNot(contains(true)));
  });

  test('a search failure fans out onSearchFailure', () async {
    stubSearch((_) =>
        Stream.value(Left(SearchEmailFailure(Exception('boom')))));
    final (:service, :observer) = registeredService();

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    expect(observer.failures, hasLength(1));
    expect(observer.results, isEmpty);
  });

  test('a second observer reuses the subscription and both receive the result',
      () async {
    final service = makeService();
    final first = _RecordingObserver();
    final second = _RecordingObserver();
    service.register(first);
    service.register(second);

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    expect(first.results, hasLength(1));
    expect(second.results, hasLength(1));
    expect(first.newSearchStarted, 1);
    expect(second.newSearchStarted, 1);
  });

  test('after the last observer unregisters, no fan-out reaches it', () async {
    final (:service, :observer) = registeredService();
    service.unregister(observer);

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    expect(observer.newSearchStarted, 0);
    expect(observer.results, isEmpty);
  });

  test('dispose stops observing and drops all observers', () async {
    final (:service, :observer) = registeredService();
    service.dispose();

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    expect(observer.results, isEmpty);
  });
}
