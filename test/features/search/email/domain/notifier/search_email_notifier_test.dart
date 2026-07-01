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
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_draft_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';

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
])
void main() {
  late MockSearchEmailInteractor searchInteractor;
  late MockSearchMoreEmailInteractor searchMoreInteractor;
  late MockRefreshChangesSearchEmailInteractor refreshInteractor;

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

  void stubRefresh([List<PresentationEmail> emails = const []]) {
    when(refreshInteractor.execute(
      any,
      any,
      limit: anyNamed('limit'),
      position: anyNamed('position'),
      sort: anyNamed('sort'),
      filter: anyNamed('filter'),
      collapseThreads: anyNamed('collapseThreads'),
      properties: anyNamed('properties'),
    )).thenAnswer((_) => Stream.value(Right(RefreshChangesSearchEmailSuccess(emails))));
  }

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
    SearchEmailFilter? draft,
  }) {
    final container = ProviderContainer(overrides: [
      if (committed != null) searchFilterProvider.overrideWithValue(committed),
      if (draft != null) searchFilterDraftProvider.overrideWithValue(draft),
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
    SearchExecutionIntent intent, {
    PresentationEmail? lastEmail,
  }) {
    return container.read(searchEmailProvider.notifier).execute(
          intent,
          session: SessionFixtures.aliceSession,
          accountId: AccountFixtures.aliceAccountId,
          properties: Properties({'id'}),
          collapseThreads: false,
          trashSpamMailboxIds: null,
          lastEmail: lastEmail,
        );
  }

  /// Runs the standard load-more (20 rows loaded, cursor [cursorDate]).
  Future<void> runLoadMore(ProviderContainer container) => runExecute(
        container,
        LoadMoreIntent(currentCount: 20, lastEmailDate: cursorDate),
        lastEmail: emailWith('last'),
      );

  setUp(() {
    searchInteractor = MockSearchEmailInteractor();
    searchMoreInteractor = MockSearchMoreEmailInteractor();
    refreshInteractor = MockRefreshChangesSearchEmailInteractor();
    Get.put<SearchEmailInteractor>(searchInteractor);
    Get.put<SearchMoreEmailInteractor>(searchMoreInteractor);
    Get.put<RefreshChangesSearchEmailInteractor>(refreshInteractor);
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
        position: 99,
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
  });

  group('RefreshChangesIntent', () {
    test('limit == currentCount and position restarts at 0', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      await runExecute(container, const RefreshChangesIntent(currentCount: 30));

      final args = capturedRefresh();
      expect(args.limit?.value, 30);
      expect(args.position, 0);
    });
  });

  group('draft isolation', () {
    test('execute reads the committed filter, never the draft', () async {
      final container = containerWith(
        committed: SearchEmailFilter(subject: 'alpha'),
        draft: SearchEmailFilter(subject: 'beta'),
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
        LoadMoreIntent(currentCount: 2, lastEmailDate: cursorDate),
        lastEmail: emailWith('e2'),
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

    test('empty load-more page sets canLoadMore false', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      stubSearch([emailWith('e1')]);
      await runExecute(container, const NewSearchIntent());

      stubSearchMore(const []);
      await runExecute(
        container,
        LoadMoreIntent(currentCount: 1, lastEmailDate: cursorDate),
        lastEmail: emailWith('e1'),
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

    test('load-more failure keeps earlier pages so a retry still appends', () async {
      final container = containerForSort(EmailSortOrderType.relevance);

      stubSearch([emailWith('e1'), emailWith('e2')]);
      await runExecute(container, const NewSearchIntent());

      // Transient load-more failure — state becomes error but must retain [e1, e2].
      answerSearchMore((_) => Stream.value(Left(SearchEmailFailure(Exception('boom')))));
      await runExecute(
        container,
        LoadMoreIntent(currentCount: 2, lastEmailDate: cursorDate),
        lastEmail: emailWith('e2'),
      );
      expect(container.read(searchEmailProvider).hasError, isTrue);

      // Retry succeeds: the new page appends to the preserved pages, not to nothing.
      stubSearchMore([emailWith('e3')]);
      await runExecute(
        container,
        LoadMoreIntent(currentCount: 2, lastEmailDate: cursorDate),
        lastEmail: emailWith('e2'),
      );
      expect(
        container.read(searchEmailProvider).value!.emails.map((e) => e.id),
        [EmailId(Id('e1')), EmailId(Id('e2')), EmailId(Id('e3'))],
      );
    });

    test('interactor stream error surfaces as AsyncError', () async {
      final container = containerForSort(EmailSortOrderType.relevance);
      answerSearch((_) => Stream.error(Exception('stream boom')));

      await runExecute(container, const NewSearchIntent());

      expect(container.read(searchEmailProvider).hasError, isTrue);
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
