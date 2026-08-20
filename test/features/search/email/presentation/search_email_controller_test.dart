import 'dart:async';

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
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_recent_search_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_email_sort_order_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
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
  late advanced_mocks.MockGetAllRecentSearchLatestInteractor
      getAllRecentSearchLatestInteractor;
  late advanced_mocks.MockStoreEmailSortOrderInteractor
      storeEmailSortOrderInteractor;
  late advanced_mocks.MockQuickSearchEmailInteractor quickSearchEmailInteractor;
  late advanced_mocks.MockSaveRecentSearchInteractor saveRecentSearchInteractor;

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

  PresentationEmail email(String id, {MailboxId? mailboxId}) => PresentationEmail(
        id: EmailId(Id(id)),
        mailboxIds: mailboxId == null ? null : {mailboxId: true},
      );

  ({PresentationEmail selectedEmail, MailboxId archiveMailboxId})
      arrangeArchiveAction() {
    final sourceMailboxId = MailboxId(Id('source'));
    final archiveMailboxId = MailboxId(Id('archive'));
    when(
      mailboxDashBoardController.getMailboxIdByRole(
        PresentationMailbox.roleArchive,
      ),
    ).thenReturn(archiveMailboxId);

    return (
      selectedEmail: email('email-to-archive', mailboxId: sourceMailboxId),
      archiveMailboxId: archiveMailboxId,
    );
  }

  void verifyArchiveMove(MailboxId archiveMailboxId) {
    verify(
      mailboxDashBoardController.moveSelectedEmailMultipleToMailboxAction(
        any,
        any,
        argThat(
          predicate<MoveToMailboxRequest>(
            (request) =>
                request.destinationMailboxId == archiveMailboxId &&
                request.emailActionType == EmailActionType.archiveMessage,
          ),
        ),
        any,
      ),
    ).called(1);
  }

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

  void verifyLoadMoreExecutedOnce() {
    verify(
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
    ).called(1);
  }

  void verifyNoLoadMoreExecuted() {
    verifyNever(
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
    );
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
    getAllRecentSearchLatestInteractor =
        advanced_mocks.MockGetAllRecentSearchLatestInteractor();
    storeEmailSortOrderInteractor =
        advanced_mocks.MockStoreEmailSortOrderInteractor();
    quickSearchEmailInteractor =
        advanced_mocks.MockQuickSearchEmailInteractor();
    saveRecentSearchInteractor =
        advanced_mocks.MockSaveRecentSearchInteractor();

    Get.put<NetworkConnectionController>(
      thread_mocks.MockNetworkConnectionController(),
    );
    Get.put<MailboxDashBoardController>(mailboxDashBoardController);
    Get.put<SearchEmailInteractor>(searchEmailInteractor);
    Get.put<SearchMoreEmailInteractor>(searchMoreEmailInteractor);

    stubMailboxDashboard();
    stubRecentSearchResult(Right(GetAllRecentSearchLatestSuccess(const [])));
    stubStoreEmailSortOrderResult(Right(StoreEmailSortOrderSuccess()));

    controller = SearchEmailController(
      quickSearchEmailInteractor,
      saveRecentSearchInteractor,
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

  test('closing search requests restoration of the mailbox email list', () {
    clearInteractions(mailboxDashBoardController);
    clearInteractions(searchController);

    controller.closeSearchView();

    verifyInOrder([
      searchController.disableAllSearchEmail(),
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread),
      mailboxDashBoardController.dispatchAction(
        argThat(isA<RestoreMailboxEmailListAfterSearchAction>()),
      ),
    ]);
  });

  test(
    'prepareForSearchHandoff hydrates the input from the committed keyword',
  () {
    const committedText = 'responsive search';
    appProviderContainer.read(searchFilterProvider.notifier).set(
          SearchEmailFilter(text: SearchQuery(committedText)),
        );
    controller.textInputSearchController.text = 'stale text';

    controller.prepareForSearchHandoff();

    expect(controller.textInputSearchController.text, committedText);
    expect(controller.currentSearchText, committedText);
  });

  test(
    'prepareForSearchHandoff clears stale input for filter-only searches',
  () {
    appProviderContainer.read(searchFilterProvider.notifier).set(
          SearchEmailFilter(from: {'alice@example.com'}),
        );
    controller.textInputSearchController.text = 'stale text';
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setCurrentSearchText('stale text');

    controller.prepareForSearchHandoff();

    expect(controller.textInputSearchController.text, isEmpty);
    expect(controller.currentSearchText, isEmpty);
  });

  test('archives selected search emails through the archive folder action', () {
    final archiveAction = arrangeArchiveAction();
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setResultSearches([archiveAction.selectedEmail]);
    controller.selectEmail(archiveAction.selectedEmail);
    expect(controller.selectionMode, SelectMode.ACTIVE);

    controller.handleSelectionEmailAction(
      EmailActionType.archiveMessage,
      controller.listResultSearch,
    );

    expect(controller.selectionMode, SelectMode.INACTIVE);
    verifyArchiveMove(archiveAction.archiveMailboxId);
  });

  test('archives an individual search email through the archive folder action', () {
    final archiveAction = arrangeArchiveAction();

    controller.pressEmailAction(
      EmailActionType.archiveMessage,
      archiveAction.selectedEmail,
      null,
    );

    verifyArchiveMove(archiveAction.archiveMailboxId);
  });

  test('patches search results after a move-to-mailbox success', () {
    final archiveAction = arrangeArchiveAction();
    when(mailboxDashBoardController.mapMailboxById).thenReturn({
      archiveAction.archiveMailboxId: PresentationMailbox(
        archiveAction.archiveMailboxId,
      ),
    });
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setSearchIsRunning(true);
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setResultSearches([archiveAction.selectedEmail]);

    mailboxDashBoardController.viewState.value = Right(
      MoveToMailboxSuccess(
        archiveAction.selectedEmail.id!,
        archiveAction.selectedEmail.mailboxIds!.keys.first,
        archiveAction.archiveMailboxId,
        MoveAction.moving,
        EmailActionType.archiveMessage,
        originalMailboxIdsWithEmailIds: {
          archiveAction.selectedEmail.mailboxIds!.keys.first: [
            archiveAction.selectedEmail.id!,
          ],
        },
        emailIdsWithReadStatus: {archiveAction.selectedEmail.id!: false},
      ),
    );

    final results = appProviderContainer
        .read(searchEmailPresentationProvider)
        .listResultSearch;
    expect(results.single.mailboxIds, {archiveAction.archiveMailboxId: true});
    expect(results.single.mailboxContain?.id, archiveAction.archiveMailboxId);
  });

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
    'load-more is a no-op before any result exists',
    () async {
      // The guard also keeps `listResultSearch.last` off an empty list.
      expect(controller.searchMoreEmailsAction, returnsNormally);
      await pumpEventQueue();

      verifyNoLoadMoreExecuted();
    },
  );

  test(
    'an empty load-more page stops further load-more requests',
    () async {
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      stubLoadMoreResult(Right(SearchMoreEmailSuccess(const [])));

      controller.searchEmailAction();
      await pumpEventQueue();
      controller.searchMoreEmailsAction();
      await pumpEventQueue();
      expect(controller.canSearchMore, isFalse);

      // Scrolling again at the end of the results must not re-hit the server.
      controller.searchMoreEmailsAction();
      await pumpEventQueue();

      verifyLoadMoreExecutedOnce();
      expect(resultIds(), ['email-1']);
    },
  );

  test(
    'load-more is a no-op once the session is gone',
    () async {
      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      controller.searchEmailAction();
      await pumpEventQueue();

      when(mailboxDashBoardController.sessionCurrent).thenReturn(null);

      // The guard also keeps the `session!` assertion from throwing.
      expect(controller.searchMoreEmailsAction, returnsNormally);
      await pumpEventQueue();

      verifyNoLoadMoreExecuted();
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
    'new search failure the handler rejects still surfaces the retry UI',
    () async {
      final handler = _RecordingUrgentExceptionHandler((_) => false);
      Get.put<UrgentExceptionHandler>(handler);

      stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
      controller.searchEmailAction();
      await pumpEventQueue();
      expect(resultIds(), ['email-1']);

      stubNewSearchResult(
        Left<Failure, Success>(SearchEmailFailure(Exception('boom'))),
      );
      controller.searchEmailAction();
      await pumpEventQueue();

      // A registered handler that rejects the exception must not re-login, and
      // must leave the ordinary failure path intact.
      expect(handler.handleCallCount, 0);
      expect(controller.listResultSearch, isEmpty);
      expect(controller.resultSearchViewState.isLeft(), isTrue);
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

  // onDeleteSearchFilterAction resolves its mutation from a map keyed by
  // QuickSearchFilter and null-asserts the lookup, so an unregistered filter
  // throws at tap time. Covering every enum value here keeps that unreachable.
  test('every quick search filter has a delete action', () {
    expect(
      deleteSearchFilterCases.map((testCase) => testCase.quickFilter).toSet(),
      QuickSearchFilter.values.toSet(),
    );
  });

  group('dashboard action worker', () {
    test(
      'SynchronizeEmailSortOrderAction commits the sort order and clears the action',
      () async {
        mailboxDashBoardController.dashBoardAction.value =
            SynchronizeEmailSortOrderAction(EmailSortOrderType.oldest);
        await pumpEventQueue();

        expect(
          controller.searchEmailFilter.sortOrderType,
          EmailSortOrderType.oldest,
        );
        verify(mailboxDashBoardController.clearDashBoardAction()).called(1);
      },
    );

    test(
      'SelectDateRangeToAdvancedSearch commits the custom receive-time range',
      () async {
        mailboxDashBoardController.dashBoardAction.value =
            SelectDateRangeToAdvancedSearch(
          receiveTime: EmailReceiveTimeType.customRange,
          startDate: DateTime.utc(2026, 1, 1),
          endDate: DateTime.utc(2026, 1, 7),
        );
        await pumpEventQueue();

        final committed = controller.searchEmailFilter;
        expect(
          committed.emailReceiveTimeType,
          EmailReceiveTimeType.customRange,
        );
        expect(committed.startDate?.value, DateTime.utc(2026, 1, 1));
        expect(committed.endDate?.value, DateTime.utc(2026, 1, 7));
        verify(mailboxDashBoardController.clearDashBoardAction()).called(1);
      },
    );

    test(
      'an unhandled dashboard action never clears the dashboard action',
      () async {
        mailboxDashBoardController.dashBoardAction.value =
            OpenAdvancedSearchViewAction();
        await pumpEventQueue();

        verifyNever(mailboxDashBoardController.clearDashBoardAction());
      },
    );
  });

  group('search suggestion flow', () {
    test(
      'getAllRecentSearchAction returns empty when the username is missing',
      () async {
        when(mailboxDashBoardController.sessionCurrent).thenReturn(null);

        final result = await controller.getAllRecentSearchAction();

        expect(result, isEmpty);
        verifyNever(
          getAllRecentSearchLatestInteractor.execute(
            any,
            any,
            limit: anyNamed('limit'),
            pattern: anyNamed('pattern'),
          ),
        );
      },
    );

    test(
      'getAllRecentSearchAction maps interactor success to the recent list',
      () async {
        final recent = [RecentSearch.now('report')];
        stubRecentSearchResult(
          Right(GetAllRecentSearchLatestSuccess(recent)),
        );

        final result =
            await controller.getAllRecentSearchAction(pattern: 'rep');

        expect(result, recent);
      },
    );

    test('saveRecentSearch is a no-op when the username is missing', () {
      when(mailboxDashBoardController.sessionCurrent).thenReturn(null);

      controller.saveRecentSearch('report');

      verifyNever(saveRecentSearchInteractor.execute(any, any, any));
    });

    test('saveRecentSearch persists the query through the interactor', () async {
      when(
        saveRecentSearchInteractor.execute(any, any, any),
      ).thenAnswer((_) => Stream.value(Right(SaveRecentSearchSuccess())));

      controller.saveRecentSearch('report');
      await pumpEventQueue();

      verify(
        saveRecentSearchInteractor.execute(
          AccountFixtures.aliceAccountId,
          SessionFixtures.aliceSession.username,
          any,
        ),
      ).called(1);
    });

    test(
      'clearing the search text clears suggestions and loads recent searches',
      () async {
        stubRecentSearchResult(
          Right(GetAllRecentSearchLatestSuccess([RecentSearch.now('report')])),
        );

        // The debouncer dedupes against its initial '' value, so move it off ''
        // first; only the coalesced final '' emission is debounced through.
        controller.onTextSearchChange('report');
        controller.onTextSearchChange('');
        await Future.delayed(const Duration(milliseconds: 600));
        await pumpEventQueue();

        expect(controller.currentSearchText, '');
        expect(controller.listSuggestionSearch, isEmpty);
        expect(
          controller.searchEmailPresentationState.listRecentSearch,
          hasLength(1),
        );
      },
    );

    test(
      'non-empty search text loads quick-search and contact suggestions',
      () async {
        when(
          quickSearchEmailInteractor.execute(
            any,
            any,
            limit: anyNamed('limit'),
            sort: anyNamed('sort'),
            filter: anyNamed('filter'),
            properties: anyNamed('properties'),
            collapseThreads: anyNamed('collapseThreads'),
          ),
        ).thenAnswer(
          (_) async => Right(QuickSearchEmailSuccess([email('suggestion-1')])),
        );
        when(
          mailboxDashBoardController.getContactSuggestion('rep'),
        ).thenAnswer((_) async => [EmailAddress(null, 'alice@example.com')]);

        controller.onTextSearchChange('rep');
        await Future.delayed(const Duration(milliseconds: 600));
        await pumpEventQueue();

        expect(
          controller.listSuggestionSearch.map((e) => e.id?.id.value),
          ['suggestion-1'],
        );
        expect(
          controller.searchEmailPresentationState.listContactSuggestionSearch,
          hasLength(1),
        );
      },
    );

    test(
      'suggestions are discarded when the search text changes mid-load',
      () async {
        final completer = Completer<Either<Failure, Success>>();
        when(
          quickSearchEmailInteractor.execute(
            any,
            any,
            limit: anyNamed('limit'),
            sort: anyNamed('sort'),
            filter: anyNamed('filter'),
            properties: anyNamed('properties'),
            collapseThreads: anyNamed('collapseThreads'),
          ),
        ).thenAnswer((_) => completer.future);
        when(
          mailboxDashBoardController.getContactSuggestion(any),
        ).thenAnswer((_) async => <EmailAddress>[]);

        controller.onTextSearchChange('rep');
        await Future.delayed(const Duration(milliseconds: 600));
        // The user keeps typing while the first quick-search is still in flight.
        appProviderContainer
            .read(searchEmailPresentationProvider.notifier)
            .setCurrentSearchText('report');
        completer.complete(
          Right(QuickSearchEmailSuccess([email('stale-suggestion')])),
        );
        await pumpEventQueue();

        // The stale page must not overwrite suggestions for the newer text.
        expect(controller.listSuggestionSearch, isEmpty);
      },
    );
  });

  group('onTextSearchSubmitted', () {
    testWidgets(
      'an email-address query applies the from filter and searches once',
      (tester) async {
        final ref = await pumpWidgetRef(tester);
        stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
        when(
          saveRecentSearchInteractor.execute(any, any, any),
        ).thenAnswer((_) => Stream.value(Right(SaveRecentSearchSuccess())));

        controller.onTextSearchSubmitted(
          ref,
          ref.context,
          'alice@example.com',
        );
        await tester.pump();

        final committed = appProviderContainer.read(searchFilterProvider);
        expect(committed.from, contains('alice@example.com'));
        expect(committed.text, isNull);
        verifyNewSearchExecutedOnce();
      },
    );

    testWidgets(
      'a plain query applies the text filter and searches once',
      (tester) async {
        final ref = await pumpWidgetRef(tester);
        stubNewSearchResult(Right(SearchEmailSuccess([email('email-1')])));
        when(
          saveRecentSearchInteractor.execute(any, any, any),
        ).thenAnswer((_) => Stream.value(Right(SaveRecentSearchSuccess())));

        controller.onTextSearchSubmitted(ref, ref.context, 'report');
        await tester.pump();

        final committed = appProviderContainer.read(searchFilterProvider);
        expect(committed.text?.value, 'report');
        verifyNewSearchExecutedOnce();
      },
    );
  });

  group('web-desktop search-results ownership guard', () {
    testWidgets('ignores executor results while web desktop', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
      when(Get.find<ResponsiveUtils>().isWebDesktop(Get.context!))
          .thenReturn(true);

      controller.onSearchResult(
        SearchEmailResult(emails: [email('desktop-1')], canLoadMore: true),
        isFreshResult: true,
      );
      await tester.pump();

      expect(controller.listResultSearch, isEmpty);
    });

    testWidgets('applies executor results when not web desktop', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
      when(Get.find<ResponsiveUtils>().isWebDesktop(Get.context!))
          .thenReturn(false);

      controller.onSearchResult(
        SearchEmailResult(emails: [email('mobile-1')], canLoadMore: true),
        isFreshResult: true,
      );
      await tester.pump();

      expect(resultIds(), ['mobile-1']);
    });

    testWidgets(
      'replayed failure hydrates mobile state without repeating the toast',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(Get.find<ResponsiveUtils>().isWebDesktop(Get.context!))
            .thenReturn(false);
        final appToast = Get.find<AppToast>() as advanced_mocks.MockAppToast;
        clearInteractions(appToast);

        controller.onSearchFailure(
          SearchEmailFailure(Exception('boom')),
          isReplay: true,
        );

        expect(controller.resultSearchViewState.isLeft(), isTrue);
        verifyNever(appToast.showToastMessageWithMultipleActions(
          any,
          any,
          actions: anyNamed('actions'),
          textColor: anyNamed('textColor'),
          backgroundColor: anyNamed('backgroundColor'),
          infinityToast: anyNamed('infinityToast'),
        ));
      },
    );
  });
}
