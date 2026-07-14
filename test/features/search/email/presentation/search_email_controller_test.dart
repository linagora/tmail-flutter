import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_email_sort_order_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../mailbox_dashboard/presentation/controller/advanced_filter_controller_test.mocks.dart'
    as advanced_mocks;
import '../../../thread/presentation/controller/thread_controller_test.mocks.dart'
    as thread_mocks;
import '../domain/notifier/search_email_notifier_test.mocks.dart'
    as notifier_mocks;

typedef _SearchFilterClearedMatcher = bool Function(
  SearchEmailFilter filter,
);

/// Records urgent exception handling in tests.
class _RecordingUrgentExceptionHandler implements UrgentExceptionHandler {
  final bool Function(dynamic exception) _isUrgent;
  int handleCallCount = 0;
  Object? lastException;

  _RecordingUrgentExceptionHandler(this._isUrgent);

  @override
  bool validateUrgentException(dynamic exception) => _isUrgent(exception);

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) {
    handleCallCount++;
    lastException = exception;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SearchEmailController controller;
  late thread_mocks.MockMailboxDashBoardController mailboxDashBoardController;
  late thread_mocks.MockSearchController searchController;
  late notifier_mocks.MockSearchEmailInteractor searchEmailInteractor;
  late notifier_mocks.MockSearchMoreEmailInteractor searchMoreEmailInteractor;
  late notifier_mocks.MockRefreshChangesSearchEmailInteractor refreshInteractor;
  late advanced_mocks.MockGetAllRecentSearchLatestInteractor
      getAllRecentSearchLatestInteractor;
  late advanced_mocks.MockStoreEmailSortOrderInteractor
      storeEmailSortOrderInteractor;

  Future<WidgetRef> pumpWidgetRef(WidgetTester tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: appProviderContainer,
        child: Consumer(
          builder: (context, widgetRef, child) {
            ref = widgetRef;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return ref;
  }

  PresentationEmail email(String id) => PresentationEmail(id: EmailId(Id(id)));

  List<String?> resultIds() =>
      controller.listResultSearch.map((email) => email.id?.id.value).toList();

  void stubNewSearchResult(Either<Failure, Success> result) {
    when(
      searchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        collapseThreads: anyNamed('collapseThreads'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      ),
    ).thenAnswer((_) => Stream.value(result));
  }

  void stubLoadMoreResult(Either<Failure, Success> result) {
    when(
      searchMoreEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        position: anyNamed('position'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        collapseThreads: anyNamed('collapseThreads'),
        lastEmailId: anyNamed('lastEmailId'),
      ),
    ).thenAnswer((_) => Stream.value(result));
  }

  void stubRefreshResult(Either<Failure, Success> result) {
    when(
      refreshInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        collapseThreads: anyNamed('collapseThreads'),
        properties: anyNamed('properties'),
      ),
    ).thenAnswer((_) => Stream.value(result));
  }

  void stubRecentSearchResult(Either<Failure, Success> result) {
    when(
      getAllRecentSearchLatestInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        pattern: anyNamed('pattern'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubStoreEmailSortOrderResult(Either<Failure, Success> result) {
    when(
      storeEmailSortOrderInteractor.execute(any),
    ).thenAnswer((_) => Stream.value(result));
  }

  void verifyNewSearchExecutedOnce() {
    verify(
      searchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        collapseThreads: anyNamed('collapseThreads'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      ),
    ).called(1);
  }

  void putBaseDependencies() {
    Get.put<CachingManager>(advanced_mocks.MockCachingManager());
    Get.put<LanguageCacheManager>(advanced_mocks.MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(
      advanced_mocks.MockAuthorizationInterceptors(),
    );
    Get.put<AuthorizationInterceptors>(
      advanced_mocks.MockAuthorizationInterceptors(),
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(
      advanced_mocks.MockDynamicUrlInterceptors(),
    );
    Get.put<DeleteCredentialInteractor>(
      advanced_mocks.MockDeleteCredentialInteractor(),
    );
    Get.put<LogoutOidcInteractor>(advanced_mocks.MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(
      advanced_mocks.MockDeleteAuthorityOidcInteractor(),
    );
    Get.put<AppToast>(advanced_mocks.MockAppToast());
    Get.put<ImagePaths>(advanced_mocks.MockImagePaths());
    Get.put<ResponsiveUtils>(advanced_mocks.MockResponsiveUtils());
    Get.put<Uuid>(advanced_mocks.MockUuid());
    Get.put<ToastManager>(advanced_mocks.MockToastManager());
    Get.put<TwakeAppManager>(advanced_mocks.MockTwakeAppManager());
  }

  void stubMailboxDashboard() {
    final accountId = Rxn(AccountFixtures.aliceAccountId);

    when(mailboxDashBoardController.accountId).thenReturn(accountId);
    when(
      mailboxDashBoardController.sessionCurrent,
    ).thenReturn(SessionFixtures.aliceSession);
    when(
      mailboxDashBoardController.currentSortOrder,
    ).thenReturn(SearchEmailFilter.defaultSortOrder);
    when(mailboxDashBoardController.trashSpamMailboxIds).thenReturn(null);
    when(mailboxDashBoardController.mapMailboxById).thenReturn({});
    when(
      mailboxDashBoardController.dashBoardAction,
    ).thenReturn(Rxn<UIAction>());
    when(
      mailboxDashBoardController.emailUIAction,
    ).thenReturn(Rxn<EmailUIAction>());
    when(
      mailboxDashBoardController.viewState,
    ).thenReturn(Rx(Right(UIState.idle)));
    when(
      mailboxDashBoardController.searchController,
    ).thenReturn(searchController);
    when(
      mailboxDashBoardController.storeEmailSortOrderInteractor,
    ).thenReturn(storeEmailSortOrderInteractor);
    when(searchController.isSearchEmailRunning).thenReturn(true);
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    appProviderContainer.invalidate(searchFilterProvider);
    appProviderContainer.invalidate(searchEmailProvider);
    appProviderContainer.invalidate(searchEmailPresentationProvider);

    putBaseDependencies();
    mailboxDashBoardController = thread_mocks.MockMailboxDashBoardController();
    searchController = thread_mocks.MockSearchController();
    searchEmailInteractor = notifier_mocks.MockSearchEmailInteractor();
    searchMoreEmailInteractor = notifier_mocks.MockSearchMoreEmailInteractor();
    refreshInteractor = notifier_mocks.MockRefreshChangesSearchEmailInteractor();
    getAllRecentSearchLatestInteractor =
        advanced_mocks.MockGetAllRecentSearchLatestInteractor();
    storeEmailSortOrderInteractor =
        advanced_mocks.MockStoreEmailSortOrderInteractor();

    Get.put<NetworkConnectionController>(
      thread_mocks.MockNetworkConnectionController(),
    );
    Get.put<MailboxDashBoardController>(mailboxDashBoardController);
    Get.put<SearchEmailInteractor>(searchEmailInteractor);
    Get.put<SearchMoreEmailInteractor>(searchMoreEmailInteractor);
    Get.put<RefreshChangesSearchEmailInteractor>(refreshInteractor);

    stubMailboxDashboard();
    stubRecentSearchResult(Right(GetAllRecentSearchLatestSuccess(const [])));
    stubStoreEmailSortOrderResult(Right(StoreEmailSortOrderSuccess()));

    controller = SearchEmailController(
      advanced_mocks.MockQuickSearchEmailInteractor(),
      advanced_mocks.MockSaveRecentSearchInteractor(),
      getAllRecentSearchLatestInteractor,
    );
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    appProviderContainer.invalidate(searchFilterProvider);
    appProviderContainer.invalidate(searchEmailProvider);
    appProviderContainer.invalidate(searchEmailPresentationProvider);
    Get.reset();
  });

  test(
    'searchEmailAction delegates new search to central executor and bridges result',
    () async {
      final firstPage = [email('email-1')];
      when(
        searchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: anyNamed('collapseThreads'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        ),
      ).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(firstPage))));

      controller.searchEmailAction();
      await pumpEventQueue();

      verify(
        searchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: false,
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        ),
      ).called(1);
      expect(resultIds(), [
        'email-1',
      ]);
    },
  );

  test(
    'searchMoreEmailsAction delegates load-more to central executor and bridges append',
    () async {
      final firstPage = [email('email-1')];
      final nextPage = [email('email-2')];
      when(
        searchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: anyNamed('collapseThreads'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        ),
      ).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(firstPage))));
      when(
        searchMoreEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          position: anyNamed('position'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: anyNamed('collapseThreads'),
          lastEmailId: anyNamed('lastEmailId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(Right(SearchMoreEmailSuccess(nextPage))),
      );

      controller.searchEmailAction();
      await pumpEventQueue();
      controller.searchMoreEmailsAction();
      await pumpEventQueue();

      verify(
        searchMoreEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          position: anyNamed('position'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: false,
          lastEmailId: firstPage.last.id,
        ),
      ).called(1);
      expect(resultIds(), [
        'email-1',
        'email-2',
      ]);
    },
  );

  test(
    'new search failure clears the result list and surfaces the failure',
    () async {
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      controller.searchEmailAction();
      await pumpEventQueue();
      expect(controller.listResultSearch, isNotEmpty);

      stubNewSearchResult(
        Left<Failure, Success>(SearchEmailFailure(Exception('boom'))),
      );
      controller.searchEmailAction();
      await pumpEventQueue();

      expect(controller.listResultSearch, isEmpty);
      expect(controller.resultSearchViewState.isLeft(), isTrue);
    },
  );

  test(
    'load-more failure keeps the current page and completes searchMoreState',
    () async {
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      stubLoadMoreResult(
        Left<Failure, Success>(SearchMoreEmailFailure(Exception('boom'))),
      );

      controller.searchEmailAction();
      await pumpEventQueue();
      controller.searchMoreEmailsAction();
      await pumpEventQueue();

      expect(resultIds(), [
        'email-1',
      ]);
      expect(controller.searchMoreState, SearchMoreState.completed);
    },
  );

  test(
    'new search urgent failure routes re-login and skips the retry UI',
    () async {
      final handler = _RecordingUrgentExceptionHandler((_) => true);
      Get.put<UrgentExceptionHandler>(handler);

      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      controller.searchEmailAction();
      await pumpEventQueue();
      expect(resultIds(), ['email-1']);

      final urgentException = Exception('expired-token');
      stubNewSearchResult(
        Left<Failure, Success>(SearchEmailFailure(urgentException)),
      );
      controller.searchEmailAction();
      await pumpEventQueue();

      expect(handler.handleCallCount, 1);
      expect(handler.lastException, urgentException);
      // Urgent failures keep the current list and state.
      expect(resultIds(), ['email-1']);
      expect(controller.resultSearchViewState.isRight(), isTrue);
    },
  );

  test(
    'load-more urgent failure routes re-login while keeping the current page',
    () async {
      final handler = _RecordingUrgentExceptionHandler((_) => true);
      Get.put<UrgentExceptionHandler>(handler);

      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      final urgentException = Exception('expired-token');
      stubLoadMoreResult(
        Left<Failure, Success>(SearchMoreEmailFailure(urgentException)),
      );

      controller.searchEmailAction();
      await pumpEventQueue();
      controller.searchMoreEmailsAction();
      await pumpEventQueue();

      expect(handler.handleCallCount, 1);
      expect(handler.lastException, urgentException);
      expect(resultIds(), ['email-1']);
      expect(controller.searchMoreState, SearchMoreState.completed);
    },
  );

  test(
    'controller filter getters read the committed searchFilterProvider (single source)',
    () async {
      appProviderContainer.read(searchFilterProvider.notifier).update(
        SearchFilterPatch()
          ..unreadOption = const Some(true)
          ..sortOrderTypeOption = const Some(EmailSortOrderType.oldest),
      );

      expect(controller.searchEmailFilter.unread, isTrue);
      expect(controller.searchEmailFilter.sortOrderType,
          EmailSortOrderType.oldest);
    },
  );

  testWidgets(
    'selectKeywordsSearchFilter appends to a fresh keyword set without mutating prior state',
    (tester) async {
      final ref = await pumpWidgetRef(tester);
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));

      final before = appProviderContainer.read(searchFilterProvider);

      controller.selectKeywordsSearchFilter(ref, KeyWordIdentifier.emailFlagged);
      await tester.pump();

      final after = appProviderContainer.read(searchFilterProvider);
      expect(after.hasKeyword, contains(KeyWordIdentifier.emailFlagged.value));
      // Keep the previous keyword set immutable for Riverpod notifications.
      expect(before.hasKeyword, isEmpty);
      expect(identical(before.hasKeyword, after.hasKeyword), isFalse);
    },
  );

  test(
    'clearAllResultSearch resets the committed filter to the default sort order',
    () async {
      appProviderContainer
          .read(searchFilterProvider.notifier)
          .update(SearchFilterPatch()..unreadOption = const Some(true));
      expect(controller.searchEmailFilter.unread, isTrue);

      controller.clearAllResultSearch();
      await pumpEventQueue();

      final committed = appProviderContainer.read(searchFilterProvider);
      expect(committed.unread, isFalse);
      expect(committed.sortOrderType, SearchEmailFilter.defaultSortOrder);
      expect(controller.searchEmailFilter.unread, isFalse);
    },
  );

  test(
    'websocket message replaces the rendered list via RefreshChangesIntent',
    () async {
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      controller.searchEmailAction();
      await pumpEventQueue();

      when(
        mailboxDashBoardController.currentEmailState,
      ).thenReturn(jmap.State('state-1'));
      stubRefreshResult(
        Right(RefreshChangesSearchEmailSuccess([
          email('email-1'),
          email('email-2'),
        ])),
      );

      await controller.handleWebSocketMessage(
        WebSocketMessage(newState: jmap.State('state-2')),
      );
      await pumpEventQueue();

      verify(
        refreshInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          collapseThreads: anyNamed('collapseThreads'),
          properties: anyNamed('properties'),
        ),
      ).called(1);
      expect(resultIds(), [
        'email-1',
        'email-2',
      ]);
    },
  );

  test(
    'websocket refresh failure keeps the rendered list (non-destructive)',
    () async {
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      controller.searchEmailAction();
      await pumpEventQueue();

      when(
        mailboxDashBoardController.currentEmailState,
      ).thenReturn(jmap.State('state-1'));
      stubRefreshResult(
        Left<Failure, Success>(SearchEmailFailure(Exception('boom'))),
      );

      await controller.handleWebSocketMessage(
        WebSocketMessage(newState: jmap.State('state-2')),
      );
      await pumpEventQueue();

      expect(resultIds(), [
        'email-1',
      ]);
      expect(controller.resultSearchViewState.isRight(), isTrue);
    },
  );

  final start = UTCDate(DateTime.utc(2026, 1, 1));
  final end = UTCDate(DateTime.utc(2026, 1, 7));
  final mailbox = PresentationMailbox(
    MailboxId(Id('inbox-id')),
    name: MailboxName('Inbox'),
  );
  final label = Label(id: Id('work-label'), displayName: 'Work');
  final flagged = KeyWordIdentifier.emailFlagged.value;
  final deleteSearchFilterCases = <({
    QuickSearchFilter quickFilter,
    SearchEmailFilter initialFilter,
    _SearchFilterClearedMatcher isCleared,
  })>[
    (
      quickFilter: QuickSearchFilter.dateTime,
      initialFilter: SearchEmailFilter(
        emailReceiveTimeType: EmailReceiveTimeType.customRange,
        startDate: start,
        endDate: end,
      ),
      isCleared: (filter) =>
        filter.emailReceiveTimeType == EmailReceiveTimeType.allTime &&
        filter.startDate == null &&
        filter.endDate == null,
    ),
    (
      quickFilter: QuickSearchFilter.last7Days,
      initialFilter: SearchEmailFilter(
        emailReceiveTimeType: EmailReceiveTimeType.last7Days,
        startDate: start,
        endDate: end,
      ),
      isCleared: (filter) =>
        filter.emailReceiveTimeType == EmailReceiveTimeType.allTime &&
        filter.startDate == null &&
        filter.endDate == null,
    ),
    (
      quickFilter: QuickSearchFilter.sortBy,
      initialFilter: SearchEmailFilter(
        sortOrderType: EmailSortOrderType.oldest,
      ),
      isCleared: (filter) =>
        filter.sortOrderType == SearchEmailFilter.defaultSortOrder,
    ),
    (
      quickFilter: QuickSearchFilter.from,
      initialFilter: SearchEmailFilter(from: const {'alice@example.com'}),
      isCleared: (filter) => filter.from.isEmpty,
    ),
    (
      quickFilter: QuickSearchFilter.fromMe,
      initialFilter: SearchEmailFilter(from: const {'alice@example.com'}),
      isCleared: (filter) => filter.from.isEmpty,
    ),
    (
      quickFilter: QuickSearchFilter.hasAttachment,
      initialFilter: SearchEmailFilter(hasAttachment: true),
      isCleared: (filter) => !filter.hasAttachment,
    ),
    (
      quickFilter: QuickSearchFilter.to,
      initialFilter: SearchEmailFilter(to: const {'bob@example.com'}),
      isCleared: (filter) => filter.to.isEmpty,
    ),
    (
      quickFilter: QuickSearchFilter.folder,
      initialFilter: SearchEmailFilter(mailbox: mailbox),
      isCleared: (filter) => filter.mailbox == null,
    ),
    (
      quickFilter: QuickSearchFilter.starred,
      initialFilter: SearchEmailFilter(hasKeyword: {'custom', flagged}),
      isCleared: (filter) =>
        !filter.hasKeyword.contains(flagged) &&
        filter.hasKeyword.contains('custom'),
    ),
    (
      quickFilter: QuickSearchFilter.unread,
      initialFilter: SearchEmailFilter(unread: true),
      isCleared: (filter) => !filter.unread,
    ),
    (
      quickFilter: QuickSearchFilter.events,
      initialFilter: SearchEmailFilter(notIncludeEvents: true),
      isCleared: (filter) => !filter.notIncludeEvents,
    ),
    (
      quickFilter: QuickSearchFilter.labels,
      initialFilter: SearchEmailFilter(label: label),
      isCleared: (filter) => filter.label == null,
    ),
  ];

  for (final testCase in deleteSearchFilterCases) {
    testWidgets(
      'delete ${testCase.quickFilter.name} clears its filter and searches once',
      (tester) async {
        final ref = await pumpWidgetRef(tester);
        appProviderContainer
            .read(searchFilterProvider.notifier)
            .set(testCase.initialFilter);
        stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));

        controller.onDeleteSearchFilterAction(
          ref,
          testCase.quickFilter,
        );
        await tester.pump();

        final committed = appProviderContainer.read(searchFilterProvider);
        expect(testCase.isCleared(committed), isTrue);
        verifyNewSearchExecutedOnce();
      },
    );
  }
}
