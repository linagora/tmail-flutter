import 'dart:async';

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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_execution_observer.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';
import 'search_executor_service_test.mocks.dart';

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

@GenerateNiceMocks([
  MockSpec<SearchEmailInteractor>(),
  MockSpec<SearchMoreEmailInteractor>(),
  MockSpec<RefreshChangesSearchEmailInteractor>(),
  MockSpec<UrgentExceptionHandler>(),
])
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

  void stubSearchMore(
      Stream<Either<Failure, Success>> Function(Invocation) answer) {
    when(searchMoreInteractor.execute(
      any,
      any,
      limit: anyNamed('limit'),
      sort: anyNamed('sort'),
      position: anyNamed('position'),
      filter: anyNamed('filter'),
      properties: anyNamed('properties'),
      collapseThreads: anyNamed('collapseThreads'),
      lastEmailId: anyNamed('lastEmailId'),
    )).thenAnswer(answer);
  }

  void stubRefresh(
      Stream<Either<Failure, Success>> Function(Invocation) answer) {
    when(refreshInteractor.execute(
      any,
      any,
      limit: anyNamed('limit'),
      position: anyNamed('position'),
      sort: anyNamed('sort'),
      filter: anyNamed('filter'),
      collapseThreads: anyNamed('collapseThreads'),
      properties: anyNamed('properties'),
    )).thenAnswer(answer);
  }

  SearchExecutorService makeService() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return SearchExecutorService(container);
  }

  _RecordingObserver registerObserver(SearchExecutorService service) {
    final observer = _RecordingObserver();
    service.register(observer);
    return observer;
  }

  SearchExecutorService serviceWithObserver() {
    final service = makeService();
    registerObserver(service);
    return service;
  }

  /// A service with a single registered observer — the common arrangement.
  ({SearchExecutorService service, _RecordingObserver observer})
      registeredService() {
    final service = makeService();
    final observer = registerObserver(service);
    return (service: service, observer: observer);
  }

  Future<void> dispatchNewSearch(SearchExecutorService service) async {
    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();
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

    await dispatchNewSearch(service);

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

    await dispatchNewSearch(service);

    final moreEmail = PresentationEmail(
      id: EmailId(Id('email2')),
      receivedAt: email.receivedAt,
    );
    stubSearchMore((_) =>
        Stream.value(Right(SearchMoreEmailSuccess([moreEmail]))));

    await service.dispatch(
      LoadMoreIntent(
        currentCount: 1,
        lastEmailDate: email.receivedAt,
        lastEmailId: email.id,
      ),
      context,
    );
    await pumpEventQueue();

    expect(observer.newSearchStarted, 1);
    expect(observer.results.last.emails, [email, moreEmail]);
    expect(observer.freshFlags.last, isFalse);
  });

  test('a search failure fans out onSearchFailure', () async {
    stubSearch((_) =>
        Stream.value(Left(SearchEmailFailure(Exception('boom')))));
    final (:service, :observer) = registeredService();

    await dispatchNewSearch(service);

    expect(observer.failures, hasLength(1));
    expect(observer.results, isEmpty);
  });

  test('an urgent search failure is not fanned out to observers', () async {
    when(urgentHandler.validateUrgentException(any)).thenReturn(true);
    stubSearch((_) =>
        Stream.value(Left(SearchEmailFailure(Exception('urgent')))));
    final (:service, :observer) = registeredService();

    await dispatchNewSearch(service);

    expect(observer.failures, isEmpty);
    expect(observer.results, isEmpty);
  });

  test('a late observer does not receive an urgent failure snapshot', () async {
    when(urgentHandler.validateUrgentException(any)).thenReturn(true);
    stubSearch((_) =>
        Stream.value(Left(SearchEmailFailure(Exception('urgent')))));
    final service = serviceWithObserver();

    await dispatchNewSearch(service);

    final lateObserver = registerObserver(service);

    expect(lateObserver.failures, isEmpty);
    expect(lateObserver.results, isEmpty);
  });

  test('a second observer reuses the subscription and both receive the result',
      () async {
    final service = makeService();
    final first = _RecordingObserver();
    final second = _RecordingObserver();
    service.register(first);
    service.register(second);

    await dispatchNewSearch(service);

    expect(first.results, hasLength(1));
    expect(second.results, hasLength(1));
    expect(first.newSearchStarted, 1);
    expect(second.newSearchStarted, 1);
  });

  test('a late observer receives the current search snapshot', () async {
    final service = serviceWithObserver();

    await dispatchNewSearch(service);

    final lateObserver = registerObserver(service);

    expect(lateObserver.results.single.emails, [email]);
    expect(lateObserver.freshFlags.single, isFalse);
    expect(lateObserver.newSearchStarted, 0);
  });

  test('a late observer receives loading before the final result', () async {
    final service = serviceWithObserver();
    final pending = Completer<Either<Failure, Success>>();
    stubSearch((_) => Stream.fromFuture(pending.future));

    final search = service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    final lateObserver = registerObserver(service);

    expect(lateObserver.loading, 1);
    expect(lateObserver.results, isEmpty);

    pending.complete(Right(SearchEmailSuccess([email])));
    await search;
    await pumpEventQueue();

    expect(lateObserver.results.single.emails, [email]);
    expect(lateObserver.freshFlags.single, isTrue);
  });

  test('a late observer receives the current search failure', () async {
    final failure = SearchEmailFailure(Exception('boom'));
    stubSearch((_) => Stream.value(Left(failure)));
    final service = serviceWithObserver();

    await dispatchNewSearch(service);

    final lateObserver = registerObserver(service);

    expect(lateObserver.failures.single, same(failure));
    expect(lateObserver.results, isEmpty);
  });

  test('refresh result is not fresh', () async {
    final (:service, :observer) = registeredService();

    await dispatchNewSearch(service);

    final refreshedEmail = PresentationEmail(
      id: EmailId(Id('refreshed-email')),
      receivedAt: email.receivedAt,
    );
    stubRefresh((_) => Stream.value(
        Right(RefreshChangesSearchEmailSuccess([refreshedEmail]))));

    await service.dispatch(
      const RefreshChangesIntent(currentCount: 1),
      context,
    );
    await pumpEventQueue();

    expect(observer.results.last.emails, [refreshedEmail]);
    expect(observer.freshFlags.last, isFalse);
  });

  test('refresh superseding a loading search never produces a fresh result',
      () async {
    final (:service, :observer) = registeredService();
    final pending = Completer<Either<Failure, Success>>();
    stubSearch((_) => Stream.fromFuture(pending.future));

    final search = service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    stubRefresh((_) => Stream.value(
        Right(RefreshChangesSearchEmailSuccess([email]))));
    await service.dispatch(
      const RefreshChangesIntent(currentCount: 0),
      context,
    );
    await pumpEventQueue();

    expect(observer.freshFlags, isNot(contains(true)));

    pending.complete(Right(SearchEmailSuccess([email])));
    await search;
    await pumpEventQueue();
    expect(observer.freshFlags, isNot(contains(true)));
  });

  test('registering the same observer twice does not replay twice', () async {
    final service = makeService();
    final observer = _RecordingObserver();
    service.register(observer);

    await dispatchNewSearch(service);

    service.register(observer);

    expect(observer.results, hasLength(1));
    expect(observer.freshFlags.single, isTrue);
  });

  test('after the last observer unregisters, no fan-out reaches it', () async {
    final (:service, :observer) = registeredService();
    service.unregister(observer);

    await dispatchNewSearch(service);

    expect(observer.newSearchStarted, 0);
    expect(observer.results, isEmpty);
  });

  test('a new observer receives the snapshot after the last observer leaves',
      () async {
    final service = makeService();
    final first = _RecordingObserver();
    service.register(first);

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();
    service.unregister(first);

    final replacement = _RecordingObserver();
    service.register(replacement);

    expect(replacement.results.single.emails, [email]);
    expect(replacement.freshFlags.single, isFalse);
  });

  test('resetSession prevents replaying a previous session snapshot', () async {
    final service = serviceWithObserver();
    await dispatchNewSearch(service);

    service.resetSession();
    final replacement = _RecordingObserver();
    service.register(replacement);

    expect(replacement.results, isEmpty);
    expect(replacement.failures, isEmpty);

    await dispatchNewSearch(service);
    expect(replacement.results, hasLength(1));
  });

  test('dispose stops observing and drops all observers', () async {
    final (:service, :observer) = registeredService();
    service.dispose();

    await service.dispatch(const NewSearchIntent(), context);
    await pumpEventQueue();

    expect(observer.results, isEmpty);
  });
}
