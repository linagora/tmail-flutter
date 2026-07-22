import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';
import 'search_email_notifier_test.mocks.dart';

/// The three interactor arguments every assertion inspects, in capture order.
typedef CapturedArgs = ({UnsignedInt? limit, int? position, Filter? filter});

/// Builds [CapturedArgs] from a mockito `captured` list — all three capture
/// `(limit, position, filter)` in this order.
CapturedArgs _argsFrom(List<dynamic> captured) => (
      limit: captured[0] as UnsignedInt?,
      position: captured[1] as int?,
      filter: captured[2] as Filter?,
    );

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

  final cursorDate = UTCDate(DateTime.parse('2021-08-10T04:00:59Z'));

  PresentationEmail emailWith(String id) => PresentationEmail(
        id: EmailId(Id(id)),
        receivedAt: cursorDate,
      );

  /// Stubs `searchInteractor.execute` with any stream [answer] — the one place its
  /// matcher list lives.
  void answerSearch(Stream<Either<Failure, Success>> Function(Invocation) answer) {
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

  void stubSearch([List<PresentationEmail> emails = const []]) =>
      answerSearch((_) => Stream.value(Right(SearchEmailSuccess(emails))));

  /// Stubs `searchMoreInteractor.execute` with any stream [answer] — the one place
  /// its matcher list lives.
  void answerSearchMore(Stream<Either<Failure, Success>> Function(Invocation) answer) {
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

  void stubSearchMore([List<PresentationEmail> emails = const []]) =>
      answerSearchMore((_) => Stream.value(Right(SearchMoreEmailSuccess(emails))));

  void answerRefresh(Stream<Either<Failure, Success>> Function(Invocation) answer) {
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

  void stubRefresh([List<PresentationEmail> emails = const []]) => answerRefresh(
      (_) => Stream.value(Right(RefreshChangesSearchEmailSuccess(emails))));

  /// Captured `(limit, position, filter)` of the single call to each interactor.
  CapturedArgs capturedSearch() => _argsFrom(verify(searchInteractor.execute(
        any,
        any,
        limit: captureAnyNamed('limit'),
        position: captureAnyNamed('position'),
        sort: anyNamed('sort'),
        filter: captureAnyNamed('filter'),
        properties: anyNamed('properties'),
        collapseThreads: anyNamed('collapseThreads'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).captured);

  CapturedArgs capturedSearchMore() => _argsFrom(verify(searchMoreInteractor.execute(
        any,
        any,
        limit: captureAnyNamed('limit'),
        sort: anyNamed('sort'),
        position: captureAnyNamed('position'),
        filter: captureAnyNamed('filter'),
        properties: anyNamed('properties'),
        collapseThreads: anyNamed('collapseThreads'),
        lastEmailId: anyNamed('lastEmailId'),
      )).captured);

  CapturedArgs capturedRefresh() => _argsFrom(verify(refreshInteractor.execute(
        any,
        any,
        limit: captureAnyNamed('limit'),
        position: captureAnyNamed('position'),
        sort: anyNamed('sort'),
        filter: captureAnyNamed('filter'),
        collapseThreads: anyNamed('collapseThreads'),
        properties: anyNamed('properties'),
      )).captured);

  ProviderContainer containerWith({
    SearchEmailFilter? committed,
  }) {
    final container = ProviderContainer(overrides: [
      if (committed != null) searchFilterProvider.overrideWithValue(committed),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  /// Container with a committed `invoice` search on [sort].
  ProviderContainer containerForSort(EmailSortOrderType sort) => containerWith(
        committed: SearchEmailFilter(subject: 'invoice', sortOrderType: sort),
      );

  Future<void> runExecute(
    ProviderContainer container,
    SearchExecutionIntent intent,
  ) {
    return container.read(searchEmailProvider.notifier).execute(
          intent,
          session: SessionFixtures.aliceSession,
          accountId: AccountFixtures.aliceAccountId,
          properties: Properties({'id'}),
          collapseThreads: false,
          trashSpamMailboxIds: null,
        );
  }

  /// Verifies the shared urgent-exception primitive routed [times] failures.
  void verifyUrgentRouted({required int times}) {
    verify(urgentHandler.handleUrgentException(
      failure: anyNamed('failure'),
      exception: anyNamed('exception'),
    )).called(times);
  }

  /// Runs the standard load-more (20 rows loaded, cursor [cursorDate]).
  Future<void> runLoadMore(ProviderContainer container) => runExecute(
        container,
        LoadMoreIntent(
          currentCount: 20,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('last')),
        ),
      );

  setUp(() {
    searchInteractor = MockSearchEmailInteractor();
    searchMoreInteractor = MockSearchMoreEmailInteractor();
    refreshInteractor = MockRefreshChangesSearchEmailInteractor();
    urgentHandler = MockUrgentExceptionHandler();
    Get.put<SearchEmailInteractor>(searchInteractor);
    Get.put<SearchMoreEmailInteractor>(searchMoreInteractor);
    Get.put<RefreshChangesSearchEmailInteractor>(refreshInteractor);
    // handleUrgentExceptionIfNeeded resolves the handler via getBinding (GetX).
    Get.put<UrgentExceptionHandler>(urgentHandler);
    when(urgentHandler.validateUrgentException(any)).thenReturn(true);
    stubSearch();
    stubSearchMore();
    stubRefresh();
  });

  tearDown(Get.reset);

  group('NewSearchIntent', () {
    test('clears load-more cursors regardless of prior SSOT values', () async {
      final committed = SearchEmailFilter(
        subject: 'invoice',
        before: cursorDate,
        after: cursorDate,
        sortOrderType: EmailSortOrderType.relevance,
      );
      final container = containerWith(committed: committed);

      await runExecute(container, const NewSearchIntent());

      final args = capturedSearch();
      expect(args.position, 0); // relevance pages by position → restart at 0
      expect((args.filter as EmailFilterCondition).before, isNull);
      expect((args.filter as EmailFilterCondition).after, isNull);
    });

    test('leaves position null on a date sort', () async {
      final committed = SearchEmailFilter(
        subject: 'invoice',
        before: cursorDate,
        sortOrderType: EmailSortOrderType.mostRecent,
      );
      final container = containerWith(committed: committed);

      await runExecute(container, const NewSearchIntent());

      final args = capturedSearch();
      expect(args.position, isNull);
      expect((args.filter as EmailFilterCondition).before, isNull);
    });
  });

  group('LoadMoreIntent', () {
    test('position sort → position == currentCount, no date cursor', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      await runLoadMore(container);

      final args = capturedSearchMore();
      expect(args.position, 20);
      expect((args.filter as EmailFilterCondition).before, isNull);
      expect((args.filter as EmailFilterCondition).after, isNull);
    });

    test('date sort (mostRecent) → before cursor only, position null', () async {
      final container = containerForSort(EmailSortOrderType.mostRecent);

      await runLoadMore(container);

      final args = capturedSearchMore();
      expect(args.position, isNull);
      expect((args.filter as EmailFilterCondition).before, cursorDate);
      expect((args.filter as EmailFilterCondition).after, isNull);
    });

    test('date sort (oldest) → after cursor only, position null', () async {
      final container = containerForSort(EmailSortOrderType.oldest);

      await runLoadMore(container);

      final args = capturedSearchMore();
      expect(args.position, isNull);
      expect((args.filter as EmailFilterCondition).after, cursorDate);
      expect((args.filter as EmailFilterCondition).before, isNull);
    });

    test('threads the intent lastEmailId to searchMore as the page anchor', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      await runLoadMore(container);

      final captured = verify(searchMoreInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        position: anyNamed('position'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        collapseThreads: anyNamed('collapseThreads'),
        lastEmailId: captureAnyNamed('lastEmailId'),
      )).captured;
      expect(captured.single, EmailId(Id('last')));
    });
  });

  group('RefreshChangesIntent', () {
    test('limit == currentCount and position restarts at 0', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      await runExecute(container, const RefreshChangesIntent(currentCount: 30));

      final args = capturedRefresh();
      expect(args.limit?.value, 30);
      expect(args.position, 0);
    });

    test('empty result refresh uses the default first-page limit', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      stubSearch(const []);
      await runExecute(container, const NewSearchIntent());

      stubRefresh([emailWith('new')]);
      await runExecute(container, const RefreshChangesIntent(currentCount: 0));

      final args = capturedRefresh();
      expect(args.limit?.value, ThreadConstants.defaultLimit.value);
      expect(
        container.read(searchEmailProvider).value?.emails.map((e) => e.id),
        [EmailId(Id('new'))],
      );
    });
  });

  // Single-notifier SSOT: the executor sources the query from the committed
  // filter only — there is no draft/staging provider to read from.
  group('committed SSOT source', () {
    test('execute reads the committed filter', () async {
      final container = containerWith(
        committed: SearchEmailFilter(subject: 'alpha'),
      );

      await runExecute(container, const NewSearchIntent());

      expect((capturedSearch().filter as EmailFilterCondition).subject, 'alpha');
    });
  });

  group('committed SSOT immutability', () {
    test('execute does not mutate the committed filter', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final committed = SearchEmailFilter(
        subject: 'invoice',
        sortOrderType: EmailSortOrderType.oldest,
      );
      container.read(searchFilterProvider.notifier).set(committed);

      await runExecute(container, const NewSearchIntent());

      expect(container.read(searchFilterProvider), committed);
    });
  });

  group('result folding', () {
    test('new search replaces, load-more appends', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      final notifier = container.read(searchEmailProvider.notifier);

      stubSearch([emailWith('e1'), emailWith('e2')]);
      await runExecute(container, const NewSearchIntent());
      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('e1')), EmailId(Id('e2'))],
      );
      expect(container.read(searchEmailProvider).value!.canLoadMore, isTrue);

      stubSearchMore([emailWith('e3')]);
      await runExecute(
        container,
        LoadMoreIntent(
          currentCount: 2,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e2')),
        ),
      );
      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('e1')), EmailId(Id('e2')), EmailId(Id('e3'))],
      );

      stubSearch([emailWith('e4')]);
      await notifier.execute(
        const NewSearchIntent(),
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        properties: Properties({'id'}),
        collapseThreads: false,
        trashSpamMailboxIds: null,
      );
      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('e4'))],
      );
    });

    test('load-more drops emails already present in the current list', () async {
      final container = containerForSort(EmailSortOrderType.mostRecent);

      stubSearch([emailWith('e1'), emailWith('e2')]);
      await runExecute(container, const NewSearchIntent());

      // The next page overlaps the boundary (e2 repeats, same timestamp) and
      // adds e3; only e3 must be appended.
      stubSearchMore([emailWith('e2'), emailWith('e3')]);
      await runExecute(
        container,
        LoadMoreIntent(
          currentCount: 2,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e2')),
        ),
      );

      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('e1')), EmailId(Id('e2')), EmailId(Id('e3'))],
      );
    });

    test('empty load-more page sets canLoadMore false', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      stubSearchMore(const []);
      await runExecute(
        container,
        LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e1')),
        ),
      );

      expect(container.read(searchEmailProvider).value!.canLoadMore, isFalse);
      expect(container.read(searchEmailProvider).value!.emails.length, 1);
    });

    test('interactor failure surfaces as AsyncError', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      final failure = SearchEmailFailure(Exception('boom'));
      answerSearch((_) => Stream.value(Left(failure)));

      await runExecute(container, const NewSearchIntent());

      final result = container.read(searchEmailProvider);
      expect(result.hasError, isTrue);
      expect(result.error, failure);
    });

    test('load-more sets loadMore inProgress while the page is in flight', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      final pending = Completer<Either<Failure, Success>>();
      answerSearchMore((_) => Stream.fromFuture(pending.future));
      final inFlight = runExecute(
        container,
        LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e1')),
        ),
      );

      // Mid-flight: the list stays visible and load-more is marked in progress.
      final loading = container.read(searchEmailProvider);
      expect(loading.value?.emails.map((e) => e.id), [EmailId(Id('e1'))]);
      expect(loading.value?.loadMore, LoadMoreState.inProgress);

      pending.complete(Right(SearchMoreEmailSuccess([emailWith('e2')])));
      await inFlight;
      expect(container.read(searchEmailProvider).value?.loadMore, LoadMoreState.idle);
    });

    test('load-more failure keeps the loaded page and flags loadMore failure', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      stubSearch([emailWith('e1'), emailWith('e2')]);
      await runExecute(container, const NewSearchIntent());

      // A load-more failure must not error the whole list — it stays in AsyncData.
      final loadMoreFailure = SearchEmailFailure(Exception('boom'));
      answerSearchMore((_) => Stream.value(Left(loadMoreFailure)));
      await runExecute(
        container,
        LoadMoreIntent(
          currentCount: 2,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e2')),
        ),
      );
      final failed = container.read(searchEmailProvider);
      expect(failed.hasError, isFalse);
      expect(
        failed.value?.emails.map((e) => e.id),
        [EmailId(Id('e1')), EmailId(Id('e2'))],
      );
      expect(failed.value?.loadMore, LoadMoreState.failure);
      // The consume seam routes the urgent exception (ADR-0103).
      verifyUrgentRouted(times: 1);

      // Retry succeeds: the new page appends to the preserved pages, back to idle.
      stubSearchMore([emailWith('e3')]);
      await runExecute(
        container,
        LoadMoreIntent(
          currentCount: 2,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e2')),
        ),
      );
      final retried = container.read(searchEmailProvider);
      expect(
        retried.value?.emails.map((e) => e.id),
        [EmailId(Id('e1')), EmailId(Id('e2')), EmailId(Id('e3'))],
      );
      expect(retried.value?.loadMore, LoadMoreState.idle);
    });

    test('refresh failure keeps the current list instead of erroring', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      answerRefresh(
          (_) => Stream.value(Left(SearchEmailFailure(Exception('boom')))));
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));

      final result = container.read(searchEmailProvider);
      expect(result.hasError, isFalse);
      expect(result.value?.emails.map((e) => e.id), [EmailId(Id('e1'))]);
    });

    test('refresh failure routes the exception through the shared primitive', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      // Keep the list unchanged; the consume seam routes it for re-login (ADR-0103).
      final refreshFailure = SearchEmailFailure(const BadCredentialsException());
      answerRefresh((_) => Stream.value(Left(refreshFailure)));
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));

      final result = container.read(searchEmailProvider);
      expect(result.hasError, isFalse);
      expect(result.value?.emails.map((e) => e.id), [EmailId(Id('e1'))]);
      verifyUrgentRouted(times: 1);
    });

    test('two identical consecutive refresh failures each route', () async {
      // Routing at the failure point (not via equality-compared state) means two
      // equal failures both route — a result field would collapse the second.
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      final refreshFailure = SearchEmailFailure(const BadCredentialsException());
      answerRefresh((_) => Stream.value(Left(refreshFailure)));
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));

      verifyUrgentRouted(times: 2);
    });

    test('a successful load-more after a refresh failure does not re-route', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      answerRefresh((_) =>
          Stream.value(Left(SearchEmailFailure(const BadCredentialsException()))));
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));

      // A following successful load-more must not re-route the stale exception.
      stubSearchMore([emailWith('e2')]);
      await runExecute(
        container,
        LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e1')),
        ),
      );
      verifyUrgentRouted(times: 1); // only the refresh failure routed
    });

    test('a refresh failure clears a load-more spinner it superseded', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      // A slow load-more is in flight (spinner on) when a refresh supersedes it.
      final slowLoadMore = Completer<Either<Failure, Success>>();
      answerSearchMore((_) => Stream.fromFuture(slowLoadMore.future));
      final stale = runExecute(
        container,
        LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e1')),
        ),
      );
      expect(
        container.read(searchEmailProvider).value?.loadMore,
        LoadMoreState.inProgress,
      );

      // The refresh fails: it keeps the list but must not leave the dropped
      // load-more's spinner stuck on.
      answerRefresh(
          (_) => Stream.value(Left(SearchEmailFailure(Exception('boom')))));
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));

      // The superseded load-more resolves last; its result is dropped as stale.
      slowLoadMore.complete(Right(SearchMoreEmailSuccess([emailWith('e2')])));
      await stale;

      final result = container.read(searchEmailProvider);
      expect(result.value?.emails.map((e) => e.id), [EmailId(Id('e1'))]);
      expect(result.value?.loadMore, LoadMoreState.idle);
    });

    test('a succeeding refresh supersedes an in-flight load-more', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      // A slow load-more is in flight (spinner on) when a refresh supersedes it.
      final slowLoadMore = Completer<Either<Failure, Success>>();
      answerSearchMore((_) => Stream.fromFuture(slowLoadMore.future));
      final stale = runExecute(
        container,
        LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e1')),
        ),
      );
      expect(
        container.read(searchEmailProvider).value?.loadMore,
        LoadMoreState.inProgress,
      );

      // The refresh succeeds and replaces the list while load-more is still open.
      stubRefresh([emailWith('r1')]);
      await runExecute(container, const RefreshChangesIntent(currentCount: 1));

      // The superseded load-more resolves last; its page must not append onto the
      // refreshed list and must not resurrect the spinner.
      slowLoadMore.complete(Right(SearchMoreEmailSuccess([emailWith('e2')])));
      await stale;

      final result = container.read(searchEmailProvider);
      expect(result.value?.emails.map((e) => e.id), [EmailId(Id('r1'))]);
      expect(result.value?.loadMore, LoadMoreState.idle);
    });

    test(
      'a refresh failure clears a new-search spinner it superseded',
      () async {
        final container = containerForSort(EmailSortOrderType.relevance);

        // A slow first page is in flight when a refresh supersedes it.
        final slowSearch = Completer<Either<Failure, Success>>();
        answerSearch((_) => Stream.fromFuture(slowSearch.future));
        final stale = runExecute(container, const NewSearchIntent());
        expect(container.read(searchEmailProvider).isLoading, isTrue);

        answerRefresh(
            (_) => Stream.value(Left(SearchEmailFailure(Exception('boom')))));
        await runExecute(
          container,
          const RefreshChangesIntent(currentCount: 0),
        );

        slowSearch.complete(Right(SearchEmailSuccess([emailWith('e1')])));
        await stale;

        final result = container.read(searchEmailProvider);
        expect(result.isLoading, isFalse);
        expect(result.hasError, isFalse);
        expect(result.value?.emails, isEmpty);
        expect(result.value?.loadMore, LoadMoreState.idle);
      },
    );

    test('an intermediate success keeps the current state', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      // SearchingState is a non-terminal success (no email list to apply).
      answerSearch((_) => Stream.value(Right(SearchingState())));

      await runExecute(container, const NewSearchIntent());

      // No page was produced, so the first-page spinner stays on.
      expect(container.read(searchEmailProvider).isLoading, isTrue);
    });

    test('interactor stream error surfaces as AsyncError', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      answerSearch((_) => Stream.error(Exception('stream boom')));

      await runExecute(container, const NewSearchIntent());

      expect(container.read(searchEmailProvider).hasError, isTrue);
    });

    test('refresh replaces the current list rather than appending', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      stubSearch([emailWith('e1'), emailWith('e2')]);
      await runExecute(container, const NewSearchIntent());

      stubRefresh([emailWith('r1')]);
      await runExecute(container, const RefreshChangesIntent(currentCount: 2));

      final result = container.read(searchEmailProvider);
      expect(result.value?.emails.map((e) => e.id), [EmailId(Id('r1'))]);
      expect(result.value?.loadMore, LoadMoreState.idle);
    });

    test('a stale load-more never appends onto a newer result', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      // A slow load-more is in flight when a new search replaces the list.
      final slowLoadMore = Completer<Either<Failure, Success>>();
      answerSearchMore((_) => Stream.fromFuture(slowLoadMore.future));
      final stale = runExecute(
        container,
        LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: cursorDate,
          lastEmailId: EmailId(Id('e1')),
        ),
      );

      stubSearch([emailWith('fresh')]);
      await runExecute(container, const NewSearchIntent());

      // The stale load-more resolves last; it must not append to [fresh].
      slowLoadMore.complete(Right(SearchMoreEmailSuccess([emailWith('e2')])));
      await stale;

      expect(
        container.read(searchEmailProvider).value?.emails.map((e) => e.id),
        [EmailId(Id('fresh'))],
      );
    });

    test('a response arriving after disposal is dropped without throwing', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      final pending = Completer<Either<Failure, Success>>();
      answerSearch((_) => Stream.fromFuture(pending.future));
      final future = runExecute(container, const NewSearchIntent());

      // Logout/session reset invalidates the provider while the search is running.
      container.dispose();
      pending.complete(Right(SearchEmailSuccess([emailWith('late')])));

      // The late result must be dropped silently, not throw UnmountedRefException.
      await expectLater(future, completes);
    });

    test('a stale response never overwrites a newer result', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      final oldResult = Completer<Either<Failure, Success>>();
      final newResult = Completer<Either<Failure, Success>>();
      final responses = [
        Stream.fromFuture(oldResult.future),
        Stream.fromFuture(newResult.future),
      ];
      var call = 0;
      answerSearch((_) => responses[call++]);

      final first = runExecute(container, const NewSearchIntent());
      final second = runExecute(container, const NewSearchIntent());

      // Newer request (2nd) resolves first, then the stale earlier one (1st).
      newResult.complete(Right(SearchEmailSuccess([emailWith('new')])));
      oldResult.complete(Right(SearchEmailSuccess([emailWith('old')])));
      await Future.wait([first, second]);

      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('new'))],
      );
    });
  });

  group('GetX bridge resilience', () {
    test('provider builds before the interactors are registered', () async {
      Get.reset(); // nothing registered yet
      final container = containerForSort(EmailSortOrderType.relevance);

      // build() must not touch GetX, so reading the notifier here can't throw.
      expect(container.read(searchEmailProvider).hasValue, isTrue);

      // Interactors register later (as the bindings would); the search then runs.
      Get.put<SearchEmailInteractor>(searchInteractor);
      stubSearch([emailWith('ok')]);
      await runExecute(container, const NewSearchIntent());

      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('ok'))],
      );
    });

    test('a missing interactor at execute time surfaces as AsyncError', () async {
      Get.reset(); // interactor never registered
      final container = containerForSort(EmailSortOrderType.relevance);

      await runExecute(container, const NewSearchIntent());

      expect(container.read(searchEmailProvider).hasError, isTrue);
    });
  });
}
