import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart' hide SearchController, State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/clean_and_get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_executor_provider.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/get_search_email_layout_owner_registry.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_email_layout_owner_registry.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_layout_coordinator.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_execution_observer.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/auto_load_more_policy.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

class _NoOpSearchObserver implements SearchExecutionObserver {
  @override
  void onNewSearchStarted() {}

  @override
  void onSearchFailure(Object error, {bool isReplay = false}) {}

  @override
  void onSearchLoading() {}

  @override
  void onSearchResult(
    SearchEmailResult result, {
    required bool isFreshResult,
  }) {}
}

class _TestSearchEmailLayoutOwnerRegistry
    extends SearchEmailLayoutOwnerRegistry {
  @override
  bool tryPrepareForSearchHandoff() => true;
}

class _ConfigurableSearchEmailLayoutOwnerRegistry
    extends SearchEmailLayoutOwnerRegistry {
  bool canPrepare = false;

  @override
  bool tryPrepareForSearchHandoff() => canPrepare;
}

class _MockQuickSearchEmailInteractor extends Mock
    implements QuickSearchEmailInteractor {}

class _MockSaveRecentSearchInteractor extends Mock
    implements SaveRecentSearchInteractor {}

class _MockGetAllRecentSearchLatestInteractor extends Mock
    implements GetAllRecentSearchLatestInteractor {}

@GenerateNiceMocks([
  // Base controller mock specs
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  // Thread controller mock specs
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<SearchController>(fallbackGenerators: fallbackGenerators),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<GetEmailsInMailboxInteractor>(),
  MockSpec<RefreshChangesEmailsInMailboxInteractor>(),
  MockSpec<LoadMoreEmailsInMailboxInteractor>(),
  MockSpec<SearchEmailInteractor>(),
  MockSpec<SearchMoreEmailInteractor>(),
  MockSpec<GetEmailByIdInteractor>(),
  MockSpec<CleanAndGetEmailsInMailboxInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declaration thread controller
  late ThreadController threadController;
  late MockNetworkConnectionController mockNetworkConnectionController;
  late MockSearchController mockSearchController;
  late MockMailboxDashBoardController mockMailboxDashBoardController;
  late MockGetEmailsInMailboxInteractor mockGetEmailsInMailboxInteractor;
  late MockRefreshChangesEmailsInMailboxInteractor mockRefreshChangesEmailsInMailboxInteractor;
  late MockLoadMoreEmailsInMailboxInteractor mockLoadMoreEmailsInMailboxInteractor;
  late MockSearchEmailInteractor mockSearchEmailInteractor;
  late MockSearchMoreEmailInteractor mockSearchMoreEmailInteractor;
  late MockGetEmailByIdInteractor mockGetEmailByIdInteractor;
  late MockCleanAndGetEmailsInMailboxInteractor mockCleanAndGetEmailsInMailboxInteractor;

  // Declaration base controller
  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockDeleteCredentialInteractor mockDeleteCredentialInteractor;
  late MockLogoutOidcInteractor mockLogoutOidcInteractor;
  late MockDeleteAuthorityOidcInteractor mockDeleteAuthorityOidcInteractor;
  late MockAppToast mockAppToast;
  late MockImagePaths mockImagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;

  setUpAll(() {
    Get.testMode = true;
    // Mock base controller
    mockCachingManager = MockCachingManager();
    mockLanguageCacheManager = MockLanguageCacheManager();
    mockAuthorizationInterceptors = MockAuthorizationInterceptors();
    mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
    mockDeleteCredentialInteractor = MockDeleteCredentialInteractor();
    mockLogoutOidcInteractor = MockLogoutOidcInteractor();
    mockDeleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
    mockAppToast = MockAppToast();
    mockImagePaths = MockImagePaths();
    mockResponsiveUtils = MockResponsiveUtils();
    mockUuid = MockUuid();
    mockToastManager = MockToastManager();
    mockTwakeAppManager = MockTwakeAppManager();

    Get.put<CachingManager>(mockCachingManager);
    Get.put<LanguageCacheManager>(mockLanguageCacheManager);
    Get.put<AuthorizationInterceptors>(mockAuthorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      mockAuthorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(mockDynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(mockDeleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(mockLogoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(mockDeleteAuthorityOidcInteractor);
    Get.put<AppToast>(mockAppToast);
    Get.put<ImagePaths>(mockImagePaths);
    Get.put<ResponsiveUtils>(mockResponsiveUtils);
    Get.put<Uuid>(mockUuid);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    // Mock thread controller
    mockNetworkConnectionController = MockNetworkConnectionController();
    mockSearchController = MockSearchController();
    mockMailboxDashBoardController = MockMailboxDashBoardController();
    mockGetEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
    mockRefreshChangesEmailsInMailboxInteractor = MockRefreshChangesEmailsInMailboxInteractor();
    mockLoadMoreEmailsInMailboxInteractor = MockLoadMoreEmailsInMailboxInteractor();
    mockSearchEmailInteractor = MockSearchEmailInteractor();
    mockSearchMoreEmailInteractor = MockSearchMoreEmailInteractor();
    mockGetEmailByIdInteractor = MockGetEmailByIdInteractor();
    mockCleanAndGetEmailsInMailboxInteractor = MockCleanAndGetEmailsInMailboxInteractor();

    Get.put<NetworkConnectionController>(mockNetworkConnectionController);
    Get.put<SearchController>(mockSearchController);
    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);
    // The central executor resolves these via Get.find, not the controller ctor.
    Get.put<SearchEmailInteractor>(mockSearchEmailInteractor);
    Get.put<SearchMoreEmailInteractor>(mockSearchMoreEmailInteractor);

  threadController = ThreadController(
      mockGetEmailsInMailboxInteractor,
      mockRefreshChangesEmailsInMailboxInteractor,
      mockLoadMoreEmailsInMailboxInteractor,
      mockGetEmailByIdInteractor,
      mockCleanAndGetEmailsInMailboxInteractor,
    );
  });

  SearchLayoutCoordinator createSearchLayoutCoordinatorForTest({
    SearchEmailLayoutOwnerRegistry? mobileOwnerRegistry,
  }) {
    final dashboardController = threadController.mailboxDashBoardController;
    final searchController = threadController.searchController;
    return SearchLayoutCoordinator(
      responsiveUtils: threadController.responsiveUtils,
      searchService: appProviderContainer.read(searchExecutorServiceProvider),
      isSearchEngaged: () =>
          appProviderContainer.read(searchViewStateProvider).isSearchEngaged ||
          searchController.isSearchEmailRunning,
      isEmailOpened: () => dashboardController.isEmailOpened,
      prepareDesktopSearchHandoff: () =>
          ThreadSearchExecutionObserver(threadController).onNewSearchStarted(),
      activateMobileSearch: () => searchController.activateSimpleSearch(),
      dispatchRoute: dashboardController.dispatchRoute,
      isClosed: () => threadController.isClosed,
      mobileOwnerRegistry: mobileOwnerRegistry ??
          const GetSearchEmailLayoutOwnerRegistry(),
    );
  }

  group('ThreadController::test', () {
    group('validateListEmailsLoadMore::test', () {
      final MailboxId selectedMailboxId = MailboxId(Id('mailboxA'));
      final emailsInCurrentMailbox = <PresentationEmail>[];

      test('SHOULD returns filtered and synced emails', () {
        // Arrange
        final emailList = [
          PresentationEmail(
            id: EmailId(Id('email1')),
            mailboxIds: {MailboxId(Id('mailbox1')): true}),
          PresentationEmail(
            id: EmailId(Id('email2')),
            mailboxIds: {selectedMailboxId: true}),
          PresentationEmail(
            id: EmailId(Id('email3')),
            mailboxIds: {selectedMailboxId: true}),
        ];

        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(PresentationMailbox(selectedMailboxId)));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList(emailsInCurrentMailbox));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        // Act
        final result = threadController.validateListEmailsLoadMore(emailList);

        // Assert
        expect(result.length, 2);
        expect(
          result.map((e) => e.id).toList(),
          containsAll([EmailId(Id('email2')), EmailId(Id('email3'))]));
      });

      test('SHOULD filters out duplicated emails', () {
        // Arrange
        final emailList = [
          PresentationEmail(
            id: EmailId(Id('email1')),
            mailboxIds: {MailboxId(Id('mailbox1')): true}),
          PresentationEmail(
            id: EmailId(Id('email2')),
            mailboxIds: {selectedMailboxId: true}),
        ];
        emailsInCurrentMailbox.add(
          PresentationEmail(
            id: EmailId(Id('email2')),
            mailboxIds: {selectedMailboxId: true}));

        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(PresentationMailbox(selectedMailboxId)));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList(emailsInCurrentMailbox));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        // Act
        final result = threadController.validateListEmailsLoadMore(emailList);

        // Assert
        expect(result.length, 0);
      });

      test('SHOULD handles empty emailList', () {
        // Arrange
        final emailList = <PresentationEmail>[];

        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(PresentationMailbox(selectedMailboxId)));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList(emailsInCurrentMailbox));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        // Act
        final result = threadController.validateListEmailsLoadMore(emailList);

        // Assert
        expect(result.isEmpty, isTrue);
      });
    });

    group('search execution', () {

      testWidgets(
        'WHEN web search receives an email state change '
        'THEN the mailbox cache refresh is still executed',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

          final emailAction = Rxn<EmailUIAction>();
          final cacheController = ThreadController(
            mockGetEmailsInMailboxInteractor,
            mockRefreshChangesEmailsInMailboxInteractor,
            mockLoadMoreEmailsInMailboxInteractor,
            mockGetEmailByIdInteractor,
            mockCleanAndGetEmailsInMailboxInteractor,
          );
          addTearDown(() {
            cacheController.onClose();
            PlatformInfo.isTestingForWeb = false;
          });

          when(mockMailboxDashBoardController.sessionCurrent)
              .thenReturn(SessionFixtures.aliceSession);
          when(mockMailboxDashBoardController.accountId)
              .thenReturn(Rxn(AccountFixtures.aliceAccountId));
          when(mockMailboxDashBoardController.currentEmailState)
              .thenReturn(jmap.State('old-state'));
          when(mockMailboxDashBoardController.selectedMailbox)
              .thenReturn(Rxn(null));
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.emailUIAction)
              .thenReturn(emailAction);
          when(mockMailboxDashBoardController.dashBoardAction)
              .thenReturn(Rxn(null));
          when(mockMailboxDashBoardController.viewState)
              .thenReturn(Rx(Right(UIState.idle)));
          when(mockMailboxDashBoardController.filterMessageOption)
              .thenReturn(Rx(FilterMessageOption.all));
          when(mockMailboxDashBoardController.mapMailboxById)
              .thenReturn({});
          when(mockMailboxDashBoardController.trashSpamMailboxIds)
              .thenReturn(null);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          when(mockRefreshChangesEmailsInMailboxInteractor.execute(
            any,
            any,
            any,
            sort: anyNamed('sort'),
            limit: anyNamed('limit'),
            propertiesCreated: anyNamed('propertiesCreated'),
            propertiesUpdated: anyNamed('propertiesUpdated'),
            emailFilter: anyNamed('emailFilter'),
            collapseThreads: anyNamed('collapseThreads'),
          )).thenAnswer((_) => Stream.value(
                Right(RefreshChangesAllEmailSuccess(emailList: const [])),
              ));

          cacheController.onInit();
          emailAction.value = RefreshChangeEmailAction(
            newState: jmap.State('new-state'),
          );

          await untilCalled(mockRefreshChangesEmailsInMailboxInteractor.execute(
            any,
            any,
            any,
            sort: anyNamed('sort'),
            limit: anyNamed('limit'),
            propertiesCreated: anyNamed('propertiesCreated'),
            propertiesUpdated: anyNamed('propertiesUpdated'),
            emailFilter: anyNamed('emailFilter'),
            collapseThreads: anyNamed('collapseThreads'),
          ));

          verify(mockRefreshChangesEmailsInMailboxInteractor.execute(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            jmap.State('old-state'),
            sort: anyNamed('sort'),
            limit: anyNamed('limit'),
            propertiesCreated: anyNamed('propertiesCreated'),
            propertiesUpdated: anyNamed('propertiesUpdated'),
            emailFilter: anyNamed('emailFilter'),
            collapseThreads: anyNamed('collapseThreads'),
          )).called(1);
        },
      );

      testWidgets(
        'WHEN thread controller in searching\n'
        'AND a new search is triggered\n'
        'THEN `SearchEmailInteractor` is invoked via a new search with no filter leak\n'
        'AND `mailboxDashBoardController.emailsInCurrentMailbox` should be cleared',
      (tester) async {
        // Arrange
        PlatformInfo.isTestingForWeb = true;
        // Web desktop inline search: the thread list owns the search results.
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
        final emailList = [
          PresentationEmail(
            id: EmailId(Id('email1')),
            subject: 'hello'),
          PresentationEmail(
            id: EmailId(Id('email2')),
            subject: 'hello')
        ];

        when(mockMailboxDashBoardController.sessionCurrent).thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList(emailList));
        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.emailUIAction).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.filterMessageOption).thenReturn(Rx(FilterMessageOption.unread));
        when(mockMailboxDashBoardController.trashSpamMailboxIds).thenReturn(null);
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.currentSelectMode).thenReturn(Rx(SelectMode.INACTIVE));
        when(mockMailboxDashBoardController.listEmailSelected).thenReturn(RxList([]));
        when(mockMailboxDashBoardController.isSelectionEnabled()).thenReturn(false);
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        when(mockSearchController.searchQuery).thenReturn(null);
        when(mockSearchController.committedSearchFilter)
            .thenReturn(SearchEmailFilter.initial());
        when(mockSearchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort:anyNamed('sort'),
          filter: anyNamed('filter'),
          collapseThreads: anyNamed('collapseThreads'),
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

        // Act
        threadController.onInit();
        threadController.searchEmail();

        await untilCalled(mockSearchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort:anyNamed('sort'),
          filter: anyNamed('filter'),
          collapseThreads: anyNamed('collapseThreads'),
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        ));

        // Assert — new search with an empty committed filter carries no leak.
        verify(mockSearchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort: anyNamed('sort'),
          filter: null,
          collapseThreads: anyNamed('collapseThreads'),
          properties: anyNamed('properties'),
        )).called(1);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.isEmpty, isTrue);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.length, equals(0));
        PlatformInfo.isTestingForWeb = false;
      });
    });

    group('_registerObxStreamListener test:', () {
      late ThreadController obxListenerController;

      setUp(() {
        obxListenerController = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
        );
      });

      tearDown(() {
        obxListenerController.onClose();
      });

      test(
        'should call _getEmailsInMailboxInteractor.execute with getLatestChanges is false '
        'when mailboxDashBoardController.selectedMailbox updated',
      () async {
        // arrange
        final mailboxBefore = PresentationMailbox(MailboxId(Id('mailbox-before-id')));
        final mailboxAfter = PresentationMailbox(MailboxId(Id('mailbox-after-id')));
        final selectedMailbox = Rxn(mailboxBefore);
        when(mockMailboxDashBoardController.sessionCurrent).thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(selectedMailbox);
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn());
        when(mockMailboxDashBoardController.emailUIAction).thenReturn(Rxn());
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList());
        when(mockMailboxDashBoardController.listEmailSelected).thenReturn(RxList());
        when(mockMailboxDashBoardController.currentSelectMode).thenReturn(Rx(SelectMode.INACTIVE));
        when(mockMailboxDashBoardController.filterMessageOption).thenReturn(Rx(FilterMessageOption.all));
        // act
        obxListenerController.onInit();
        mockMailboxDashBoardController.selectedMailbox.value = mailboxAfter;
        await untilCalled(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
          getLatestChanges: false,
        ));
        
        // assert
        verify(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
          getLatestChanges: false,
        ));
      });
    });

    group('limitEmailFetched::test', () {
      late RxList<PresentationEmail> emailsRxList;
      late ThreadController limitEmailFetchedController;

      setUp(() {
        emailsRxList = RxList<PresentationEmail>();

        limitEmailFetchedController = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
        );

        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn());
        when(mockMailboxDashBoardController.emailUIAction).thenReturn(Rxn());
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(emailsRxList);
        when(mockMailboxDashBoardController.listEmailSelected).thenReturn(RxList());
        when(mockMailboxDashBoardController.currentSelectMode).thenReturn(Rx(SelectMode.INACTIVE));
        when(mockMailboxDashBoardController.filterMessageOption).thenReturn(Rx(FilterMessageOption.all));
        limitEmailFetchedController.onInit();
      });

      tearDown(() {
        limitEmailFetchedController.onClose();
      });

      List<PresentationEmail> generateEmails(int count, {String prefix = 'email'}) {
        return List.generate(
          count,
          (i) => PresentationEmail(id: EmailId(Id('$prefix$i'))),
        );
      }

      test(
        'SHOULD return defaultLimit\n'
        'WHEN no emails loaded',
      () {
        // Assert
        expect(limitEmailFetchedController.limitEmailFetched, ThreadConstants.defaultLimit);
      });

      test(
        'SHOULD return email count\n'
        'WHEN emails are loaded into the list',
      () {
        // Act
        emailsRxList.addAll(generateEmails(40));

        // Assert
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(40));
      });

      test(
        'SHOULD retain peak count\n'
        'WHEN emails are bulk deleted from the list',
      () {
        // Arrange
        emailsRxList.addAll(generateEmails(40));

        // Act - simulate bulk delete (removeWhere)
        emailsRxList.removeRange(0, 20);

        // Assert - peak should still be 40, not 20
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(40));
      });

      test(
        'SHOULD reset to defaultLimit\n'
        'WHEN resetToOriginalValue is called (mailbox switch)',
      () {
        // Arrange
        emailsRxList.addAll(generateEmails(40));
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(40));

        // Act
        limitEmailFetchedController.resetToOriginalValue();

        // Assert
        expect(limitEmailFetchedController.limitEmailFetched, ThreadConstants.defaultLimit);
      });

      test(
        'SHOULD track peak across load-more then delete\n'
        'WHEN emails are loaded incrementally and then partially deleted',
      () {
        // Arrange - simulate initial load + 2 load-mores
        emailsRxList.addAll(generateEmails(20, prefix: 'init'));
        emailsRxList.addAll(generateEmails(20, prefix: 'more1'));
        emailsRxList.addAll(generateEmails(20, prefix: 'more2'));
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(60));

        // Act - delete 30 emails
        emailsRxList.removeRange(0, 30);

        // Assert - peak was 60
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(60));
      });

      test(
        'SHOULD reset between mailbox switches\n'
        'WHEN switching to a mailbox with fewer emails',
      () {
        // Arrange - first mailbox has 40 emails
        emailsRxList.addAll(generateEmails(40));
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(40));

        // Act - switch mailbox (reset) then load fewer emails
        limitEmailFetchedController.resetToOriginalValue();
        emailsRxList.addAll(generateEmails(15, prefix: 'new'));

        // Assert - peak should be 15, not stale 40
        expect(limitEmailFetchedController.limitEmailFetched, UnsignedInt(15));
      });
    });

    group('shouldAutoLoadMoreByScrollExtent unit test:', () {
      test(
        'GIVEN maxScrollExtent is 0 '
        'WHEN content exactly fills the viewport '
        'THEN SHOULD return true',
      () {
        expect(AutoLoadMorePolicy.shouldAutoLoadMoreByScrollExtent(0), isTrue);
      });

      test(
        'GIVEN maxScrollExtent is positive '
        'WHEN content overflows the viewport '
        'THEN SHOULD return false',
      () {
        expect(AutoLoadMorePolicy.shouldAutoLoadMoreByScrollExtent(1), isFalse);
      });

      test(
        'GIVEN maxScrollExtent is 785 with viewport 816 '
        'WHEN content fills between 1× and 2× the viewport (large-screen device) '
        'THEN SHOULD return false to prevent infinite load-more loop',
      () {
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByScrollExtent(785.0459770114941),
          isFalse,
        );
      });
    });

    group('shouldAutoLoadMoreByScrollExtent widget test:', () {
      testWidgets(
        'GIVEN a ListView whose content overflows the viewport '
        'THEN maxScrollExtent > 0 and SHOULD return false',
      (tester) async {
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
            height: 500,
            child: ListView.builder(
              controller: scrollController,
              itemCount: 20,
              itemBuilder: (_, __) => const SizedBox(height: 80),
            ),
          ),
        ));

        final maxScroll = scrollController.position.maxScrollExtent;
        expect(maxScroll, greaterThan(0));
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByScrollExtent(maxScroll),
          isFalse,
        );
      });

      testWidgets(
        'GIVEN a ListView whose content does not fill the viewport '
        'THEN maxScrollExtent == 0 and SHOULD return true',
      (tester) async {
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
            height: 500,
            child: ListView.builder(
              controller: scrollController,
              itemCount: 3,
              itemBuilder: (_, __) => const SizedBox(height: 80),
            ),
          ),
        ));

        final maxScroll = scrollController.position.maxScrollExtent;
        expect(maxScroll, 0.0);
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByScrollExtent(maxScroll),
          isTrue,
        );
      });
    });

    group('canLoadMore after getAllEmail completes test:', () {
      final mailboxId = MailboxId(Id('inbox'));

      List<PresentationEmail> makeEmails(int count) => List.generate(
        count,
        (i) => PresentationEmail(
          id: EmailId(Id('e$i')),
          mailboxIds: {mailboxId: true},
        ),
      );

      void setupMocksForOnDone() {
        PlatformInfo.isTestingForWeb = false;
        when(mockMailboxDashBoardController.isEmailListDisplayed).thenReturn(false);
      }

      tearDown(() => PlatformInfo.isTestingForWeb = false);

      test(
        'GIVEN server returns fewer than limit emails '
        'WHEN getAllEmail stream completes (e.g. mailbox with 3 emails) '
        'THEN canLoadMore SHOULD be false — no Load More button',
      () {
        setupMocksForOnDone();
        final emails = makeEmails(3);
        threadController.viewState.value = Right(
          GetAllEmailSuccess(emailList: emails, currentMailboxId: mailboxId),
        );

        threadController.onDone();

        expect(threadController.canLoadMore, isFalse);
      });

      test(
        'GIVEN server returns exactly limit emails '
        'WHEN getAllEmail stream completes '
        'THEN canLoadMore SHOULD be true — more may exist',
      () {
        setupMocksForOnDone();
        final emails = makeEmails(ThreadConstants.maxCountEmails);
        threadController.viewState.value = Right(
          GetAllEmailSuccess(emailList: emails, currentMailboxId: mailboxId),
        );

        threadController.onDone();

        expect(threadController.canLoadMore, isTrue);
      });

      test(
        'GIVEN server returns an empty list '
        'WHEN getAllEmail stream completes (empty mailbox) '
        'THEN canLoadMore SHOULD be false',
      () {
        setupMocksForOnDone();
        threadController.viewState.value = Right(
          GetAllEmailSuccess(emailList: makeEmails(0), currentMailboxId: mailboxId),
        );

        threadController.onDone();

        expect(threadController.canLoadMore, isFalse);
      });

      test(
        'GIVEN getAllEmail fails and auto-load is not active '
        'WHEN the stream completes with GetAllEmailFailure '
        'THEN canLoadMore SHOULD be false',
      () {
        setupMocksForOnDone();
        threadController.canLoadMore = true;
        threadController.viewState.value =
            Left(GetAllEmailFailure(Exception('boom')));

        threadController.onDone();

        expect(threadController.canLoadMore, isFalse);
      });
    });

    group('canLoadMore after loadMoreEmails completes test:', () {
      final mailboxId = MailboxId(Id('inbox'));

      List<PresentationEmail> makeEmails(int count) => List.generate(
        count,
        (i) => PresentationEmail(
          id: EmailId(Id('lm$i')),
          mailboxIds: {mailboxId: true},
        ),
      );

      void setupMocksForLoadMore() {
        PlatformInfo.isTestingForWeb = false;
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
      }

      tearDown(() => PlatformInfo.isTestingForWeb = false);

      test(
        'GIVEN server returns fewer than limit emails in load-more response '
        'WHEN the last page has fewer items (e.g. 5 remaining) '
        'THEN canLoadMore SHOULD be false immediately — no extra empty request needed',
      () {
        setupMocksForLoadMore();
        final emails = makeEmails(5);

        threadController.handleSuccessViewState(LoadMoreEmailsSuccess(
          emails,
          serverEmailCount: emails.length,
        ));

        expect(threadController.canLoadMore, isFalse);
      });

      test(
        'GIVEN server returns exactly limit emails in load-more response '
        'WHEN more pages may exist '
        'THEN canLoadMore SHOULD be true',
      () {
        setupMocksForLoadMore();
        final emails = makeEmails(ThreadConstants.maxCountEmails);

        threadController.handleSuccessViewState(LoadMoreEmailsSuccess(
          emails,
          serverEmailCount: emails.length,
        ));

        expect(threadController.canLoadMore, isTrue);
      });

      test(
        'GIVEN server returns 0 emails in load-more response '
        'WHEN all emails have been loaded '
        'THEN canLoadMore SHOULD be false',
      () {
        setupMocksForLoadMore();

        threadController.handleSuccessViewState(LoadMoreEmailsSuccess(
          [],
          serverEmailCount: 0,
        ));

        expect(threadController.canLoadMore, isFalse);
      });

      test(
        'REGRESSION GIVEN a full server page whose anchor was stripped by the repo '
        '(arrives here as limit-1 = 19 all-new emails) '
        'WHEN more pages still exist on the server '
        'THEN canLoadMore SHOULD be true — a 19-item page must NOT be read as end-of-list',
      () {
        setupMocksForLoadMore();
        final emails = makeEmails(ThreadConstants.maxCountEmails - 1);

        threadController.handleSuccessViewState(LoadMoreEmailsSuccess(
          emails,
          serverEmailCount: ThreadConstants.maxCountEmails,
        ));

        expect(threadController.canLoadMore, isTrue);
      });

      test(
        'REGRESSION GIVEN a full server page contains no appendable email '
        'WHEN the pagination cursor cannot advance '
        'THEN load more SHOULD stop to prevent repeating the same JMAP request',
      () {
        setupMocksForLoadMore();
        final emails = makeEmails(ThreadConstants.maxCountEmails);
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList(emails));

        threadController.handleSuccessViewState(LoadMoreEmailsSuccess(
          emails,
          serverEmailCount: ThreadConstants.maxCountEmails,
        ));

        expect(threadController.canLoadMore, isFalse);
        expect(
          threadController.loadingMoreStatus.value,
          LoadingMoreStatus.completed,
        );
      });
    });

    group('canLoadMore lifecycle & guard regression:', () {
      tearDown(() {
        appProviderContainer
            .read(searchEmailPresentationProvider.notifier)
            .resetSearchMore();
      });

      test(
        'GIVEN canLoadMore was exhausted (false) '
        'WHEN resetToOriginalValue runs (e.g. switching mailbox) '
        'THEN canLoadMore SHOULD be re-enabled so the new mailbox can paginate',
      () {
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.listEmailSelected)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.currentSelectMode)
            .thenReturn(Rx(SelectMode.INACTIVE));
        threadController.canLoadMore = false;

        threadController.resetToOriginalValue();

        expect(threadController.canLoadMore, isTrue);
      });

      test(
        'GIVEN a load-more request failed '
        'WHEN handleFailureViewState receives LoadMoreEmailsFailure '
        'THEN canLoadMore SHOULD be true so the user can retry',
      () {
        threadController.canLoadMore = false;

        threadController.handleFailureViewState(
          LoadMoreEmailsFailure(Exception('network')),
        );

        expect(threadController.canLoadMore, isTrue);
      });

      test(
        'GIVEN canLoadMore is false and search is not active '
        'WHEN handleLoadMoreEmailsRequest is invoked '
        'THEN the load-more interactor SHOULD NOT be called — the guard blocks it',
      () {
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        threadController.canLoadMore = false;

        threadController.handleLoadMoreEmailsRequest();

        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));
      });

      test(
        'GIVEN search is active '
        'WHEN handleLoadMoreEmailsRequest is invoked '
        'THEN it invokes search-more, NOT load-more (canLoadMore is not consulted)',
      () async {
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        appProviderContainer
            .read(searchEmailPresentationProvider.notifier)
            .setCanSearchMore(true);
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.trashSpamMailboxIds)
            .thenReturn(null);
        final email = PresentationEmail(id: EmailId(Id('search-more-email')));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([email]));
        when(mockSearchMoreEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          position: anyNamed('position'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: anyNamed('collapseThreads'),
          lastEmailId: anyNamed('lastEmailId'),
        )).thenAnswer((_) => Stream.value(Right(SearchMoreEmailSuccess([]))));
        threadController.canLoadMore = false;

        threadController.handleLoadMoreEmailsRequest();

        await untilCalled(mockSearchMoreEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          position: anyNamed('position'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: anyNamed('collapseThreads'),
          lastEmailId: anyNamed('lastEmailId'),
        ));

        verify(mockSearchMoreEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          position: anyNamed('position'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          collapseThreads: anyNamed('collapseThreads'),
          lastEmailId: anyNamed('lastEmailId'),
        )).called(1);
        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));
      });

      test(
        'REGRESSION GIVEN a mailbox load-more request is still running '
        'WHEN another scroll notification requests load more '
        'THEN only one request SHOULD be sent',
      () async {
        final pendingRequest = Completer<void>();
        final controllerUnderTest = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
        );
        addTearDown(controllerUnderTest.onClose);
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(MailboxId(Id('inbox')))));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(Rx(FilterMessageOption.all));
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any))
            .thenAnswer((_) async* {
          await pendingRequest.future;
          yield Right(LoadMoreEmailsSuccess([], serverEmailCount: 0));
        });
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);

        controllerUnderTest.handleLoadMoreEmailsRequest();
        controllerUnderTest.handleLoadMoreEmailsRequest();

        verify(mockLoadMoreEmailsInMailboxInteractor.execute(any)).called(1);
        expect(
          controllerUnderTest.loadingMoreStatus.value,
          LoadingMoreStatus.running,
        );

        pendingRequest.complete();
        await pumpEventQueue();
      });
    });

    group('auto-load-more collapseThreads partial-page edge case test:', () {
      final mailboxId = MailboxId(Id('inbox'));

      List<PresentationEmail> makeEmails(int count) => List.generate(
        count,
        (i) => PresentationEmail(
          id: EmailId(Id('ct$i')),
          mailboxIds: {mailboxId: true},
        ),
      );

      late ThreadController collapseController;

      setUp(() {
        collapseController = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
        );
      });

      tearDown(() {
        PlatformInfo.isTestingForWeb = false;
        collapseController.onClose();
      });

      testWidgets(
        'GIVEN collapseThreads returns a partial page (< maxCountEmails threads) '
        'AND the list content does not fill the viewport (maxScrollExtent = 0) '
        'WHEN getAllEmail stream completes '
        'THEN auto-load-more IS triggered to fill the viewport '
        'AND canLoadMore reflects the subsequent load-more server response',
      (tester) async {
        PlatformInfo.isTestingForWeb = false;

        final partialEmails = makeEmails(15); // fewer than maxCountEmails = 20

        when(mockMailboxDashBoardController.isEmailListDisplayed).thenReturn(false);
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList(partialEmails));
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(Rx(FilterMessageOption.all));
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any))
            .thenAnswer((_) => Stream.value(
              Right(LoadMoreEmailsSuccess([], serverEmailCount: 0)),
            ));

        // Mount an empty ListView so listEmailController.hasClients = true
        // and maxScrollExtent = 0 (content does not fill viewport).
        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
            height: 600,
            child: ListView(controller: collapseController.listEmailController),
          ),
        ));

        expect(
          collapseController.listEmailController.position.maxScrollExtent,
          0.0,
        );

        collapseController.viewState.value = Right(
          GetAllEmailSuccess(emailList: partialEmails, currentMailboxId: mailboxId),
        );

        collapseController.onDone();
        await tester.pumpAndSettle();

        // Load-more interactor MUST be called to attempt filling the viewport.
        verify(mockLoadMoreEmailsInMailboxInteractor.execute(any)).called(1);

        // After the empty load-more response (serverEmailCount = 0 < maxCountEmails),
        // canLoadMore is set to false by _loadMoreEmailsSuccess.
        expect(collapseController.canLoadMore, isFalse);
      });

      test(
        'GIVEN collapseThreads returns a partial page (< maxCountEmails threads) '
        'AND canLoadMore is initially true before the call '
        'WHEN viewport is already full (_isAutoLoadMore = false) '
        'THEN canLoadMore SHOULD be false — no spurious Load More button',
      () {
        PlatformInfo.isTestingForWeb = false;
        // No scroll controller client → _isAutoLoadMore = false
        when(mockMailboxDashBoardController.isEmailListDisplayed).thenReturn(false);

        final partialEmails = makeEmails(15);
        threadController.canLoadMore = true;
        threadController.viewState.value = Right(
          GetAllEmailSuccess(emailList: partialEmails, currentMailboxId: mailboxId),
        );

        threadController.onDone();

        expect(threadController.canLoadMore, isFalse);
        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));
      });
    });

    group('SearchLayoutCoordinator test:', () {
      final searchEmails = List.generate(
        30,
        (index) => PresentationEmail(id: EmailId(Id('search-$index'))),
      );
      final dispatchContext = SearchDispatchContext(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        properties: Properties({'id'}),
        collapseThreads: false,
        trashSpamMailboxIds: null,
      );

      setUp(() {
        reset(mockResponsiveUtils);
        reset(mockSearchController);
        reset(mockMailboxDashBoardController);
        reset(mockSearchEmailInteractor);
        appProviderContainer.invalidate(searchExecutorServiceProvider);
        appProviderContainer.invalidate(searchEmailProvider);
        appProviderContainer.invalidate(searchEmailPresentationProvider);
        appProviderContainer.invalidate(searchViewStateProvider);
      });

      tearDown(() async {
        if (Get.isRegistered<SearchEmailController>()) {
          await Get.delete<SearchEmailController>(force: true);
        }
        if (Get.isRegistered<QuickSearchEmailInteractor>()) {
          await Get.delete<QuickSearchEmailInteractor>(force: true);
        }
        if (Get.isRegistered<SaveRecentSearchInteractor>()) {
          await Get.delete<SaveRecentSearchInteractor>(force: true);
        }
        if (Get.isRegistered<GetAllRecentSearchLatestInteractor>()) {
          await Get.delete<GetAllRecentSearchLatestInteractor>(force: true);
        }
        appProviderContainer.invalidate(searchExecutorServiceProvider);
        appProviderContainer.invalidate(searchEmailProvider);
        appProviderContainer.invalidate(searchEmailPresentationProvider);
        appProviderContainer.invalidate(searchViewStateProvider);
        PlatformInfo.isTestingForWeb = false;
        reset(mockResponsiveUtils);
        reset(mockSearchController);
        reset(mockMailboxDashBoardController);
        reset(mockSearchEmailInteractor);
      });

      void stubSearchExecution() {
        when(mockSearchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort: anyNamed('sort'),
          filter: anyNamed('filter'),
          collapseThreads: anyNamed('collapseThreads'),
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        )).thenAnswer(
          (_) => Stream.value(Right(SearchEmailSuccess(searchEmails))),
        );
      }

      void stubActiveSearchWithOpenEmail() {
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        when(mockMailboxDashBoardController.isEmailOpened).thenReturn(true);
      }

      testWidgets(
        'active search handed to desktop replays the SSOT into the thread list',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          PlatformInfo.isTestingForWeb = false;
          final displayedEmails = <PresentationEmail>[].obs;
          when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
          when(mockMailboxDashBoardController.emailsInCurrentMailbox)
              .thenReturn(displayedEmails);
          when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
          when(mockMailboxDashBoardController.selectedMailbox)
              .thenReturn(Rxn(null));
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.isSelectionEnabled())
              .thenReturn(false);
          when(mockMailboxDashBoardController.updateEmailList(any)).thenAnswer(
            (invocation) => displayedEmails.assignAll(
              invocation.positionalArguments.first
                  as List<PresentationEmail>,
            ),
          );
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          when(mockSearchController.searchQuery).thenReturn(null);
          stubSearchExecution();
          final service =
              appProviderContainer.read(searchExecutorServiceProvider);
          final observer = ThreadSearchExecutionObserver(threadController);
          service.register(observer);
          addTearDown(() => service.unregister(observer));
          await service.dispatch(const NewSearchIntent(), dispatchContext);
          await tester.pump();
          expect(displayedEmails, hasLength(searchEmails.length));
          displayedEmails.clear();
          clearInteractions(mockMailboxDashBoardController);

          createSearchLayoutCoordinatorForTest().reconcile(true);

          expect(displayedEmails, hasLength(searchEmails.length));
          verify(
            mockMailboxDashBoardController.dispatchRoute(
              DashboardRoutes.thread,
            ),
          ).called(1);
        },
      );

      testWidgets(
        'active search handed to mobile creates its binding and hydrates it',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          // Reset so web-only navigation-route generation (Uri.base.origin,
          // which throws on the VM test host's file:// scheme) is skipped.
          PlatformInfo.isTestingForWeb = false;
          when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(false);
          when(mockMailboxDashBoardController.dashBoardAction)
              .thenReturn(Rxn(null));
          when(mockMailboxDashBoardController.viewState)
              .thenReturn(Rx(Right(UIState.idle)));
          when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.accountId).thenReturn(Rxn(null));
          when(mockMailboxDashBoardController.sessionCurrent).thenReturn(null);
          when(mockMailboxDashBoardController.currentSortOrder)
              .thenReturn(EmailSortOrderType.mostRecent);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          const desktopSearchText = 'responsive search';
          appProviderContainer.read(searchFilterProvider.notifier).set(
            SearchEmailFilter(text: SearchQuery(desktopSearchText)),
          );
          Get.put<QuickSearchEmailInteractor>(
            _MockQuickSearchEmailInteractor(),
          );
          Get.put<SaveRecentSearchInteractor>(
            _MockSaveRecentSearchInteractor(),
          );
          Get.put<GetAllRecentSearchLatestInteractor>(
            _MockGetAllRecentSearchLatestInteractor(),
          );
          stubSearchExecution();
          final service =
              appProviderContainer.read(searchExecutorServiceProvider);
          final observer = _NoOpSearchObserver();
          service.register(observer);
          addTearDown(() => service.unregister(observer));
          await service.dispatch(const NewSearchIntent(), dispatchContext);
          await tester.pump();

          createSearchLayoutCoordinatorForTest().reconcile(false);
          await tester.pump();

          expect(Get.isRegistered<SearchEmailController>(), isTrue);
          expect(
            appProviderContainer
                .read(searchEmailPresentationProvider)
                .listResultSearch,
            hasLength(searchEmails.length),
          );
          expect(
            appProviderContainer
                .read(searchEmailPresentationProvider)
                .searchIsRunning,
            isTrue,
          );
          expect(
            Get.find<SearchEmailController>()
                .textInputSearchController
                .text,
            desktopSearchText,
          );
          expect(
            appProviderContainer
                .read(searchEmailPresentationProvider)
                .currentSearchText,
            desktopSearchText,
          );
          verify(mockSearchController.activateSimpleSearch()).called(1);
          verify(
            mockMailboxDashBoardController.dispatchRoute(
              DashboardRoutes.searchEmail,
            ),
          ).called(1);
        },
      );

      test(
        'REGRESSION active search handed to desktop keeps an open email detail',
      () {
        stubActiveSearchWithOpenEmail();

        createSearchLayoutCoordinatorForTest().reconcile(true);

        verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
      });

      test(
        'REGRESSION active search handed to mobile keeps an open email detail',
      () {
        stubActiveSearchWithOpenEmail();

        createSearchLayoutCoordinatorForTest(
          mobileOwnerRegistry: _TestSearchEmailLayoutOwnerRegistry(),
        ).reconcile(false);

        verify(mockSearchController.activateSimpleSearch()).called(1);
        verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
      });

      test(
        'REGRESSION mobile handoff keeps desktop presentation ownership '
        'so closing search on mobile restores the mailbox list',
      () {
        stubActiveSearchWithOpenEmail();
        final coordinator = createSearchLayoutCoordinatorForTest(
          mobileOwnerRegistry: _TestSearchEmailLayoutOwnerRegistry(),
        );

        coordinator.markDesktopSearchPresentation();
        coordinator.reconcile(false);

        expect(coordinator.takeDesktopSearchPresentation(), isTrue);
      });

      test('mobile handoff without desktop presentation leaves ownership unset',
      () {
        stubActiveSearchWithOpenEmail();
        final coordinator = createSearchLayoutCoordinatorForTest(
          mobileOwnerRegistry: _TestSearchEmailLayoutOwnerRegistry(),
        );

        coordinator.reconcile(false);

        expect(coordinator.takeDesktopSearchPresentation(), isFalse);
      });

      test('desktop handoff records desktop presentation ownership', () {
        stubActiveSearchWithOpenEmail();
        final coordinator = createSearchLayoutCoordinatorForTest();

        coordinator.reconcile(true);

        expect(coordinator.takeDesktopSearchPresentation(), isTrue);
      });

      test('no active search is a no-op', () {
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        createSearchLayoutCoordinatorForTest().reconcile(true);

        verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
      });

      test('width changes inside the same breakpoint are a no-op', () {
        when(mockResponsiveUtils.isMatchedDesktopWidth(any))
            .thenReturn(false);
        final coordinator = createSearchLayoutCoordinatorForTest();

        coordinator.handleBrowserWidthChange(800);
        coordinator.handleBrowserWidthChange(900);

        verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
      });

      testWidgets(
        'failed mobile handoff retries after the owner becomes available',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          when(mockResponsiveUtils.isMatchedDesktopWidth(any)).thenAnswer(
            (invocation) =>
                (invocation.positionalArguments.first as double) >= 1200,
          );
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.isEmailOpened)
              .thenReturn(false);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          final ownerRegistry =
              _ConfigurableSearchEmailLayoutOwnerRegistry();
          final coordinator = createSearchLayoutCoordinatorForTest(
            mobileOwnerRegistry: ownerRegistry,
          );

          coordinator.handleBrowserWidthChange(1200);
          await tester.pump();
          coordinator.handleBrowserWidthChange(900);
          await tester.pump();

          verifyNever(mockSearchController.activateSimpleSearch());
          verifyNever(mockMailboxDashBoardController.dispatchRoute(any));

          ownerRegistry.canPrepare = true;
          clearInteractions(mockSearchController);
          clearInteractions(mockMailboxDashBoardController);
          coordinator.handleBrowserWidthChange(900);
          await tester.pump();

          verify(mockSearchController.activateSimpleSearch()).called(1);
          verify(
            mockMailboxDashBoardController.dispatchRoute(
              DashboardRoutes.searchEmail,
            ),
          ).called(1);
        },
      );

      testWidgets(
        'breakpoint crossing reconciles only after the next frame',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          when(mockResponsiveUtils.isMatchedDesktopWidth(any)).thenAnswer(
            (invocation) =>
                (invocation.positionalArguments.first as double) >= 1200,
          );
          when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.emailsInCurrentMailbox)
              .thenReturn(RxList([]));
          when(mockSearchController.isSearchEmailRunning).thenReturn(false);
          final coordinator = createSearchLayoutCoordinatorForTest();
          coordinator.handleBrowserWidthChange(900);
          await tester.pump();
          clearInteractions(mockMailboxDashBoardController);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          coordinator.handleBrowserWidthChange(1200);

          verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
          await tester.pump();
          verify(
            mockMailboxDashBoardController.dispatchRoute(
              DashboardRoutes.thread,
            ),
          ).called(1);
        },
      );

      testWidgets(
        'crossing back before the frame drops the stale handoff',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          when(mockResponsiveUtils.isMatchedDesktopWidth(any)).thenAnswer(
            (invocation) =>
                (invocation.positionalArguments.first as double) >= 1200,
          );
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockSearchController.isSearchEmailRunning).thenReturn(false);
          final coordinator = createSearchLayoutCoordinatorForTest();
          coordinator.handleBrowserWidthChange(1200);
          await tester.pump();
          clearInteractions(mockMailboxDashBoardController);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          coordinator.handleBrowserWidthChange(900);
          coordinator.handleBrowserWidthChange(1200);
          await tester.pump();

          verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
        },
      );

      testWidgets(
        'separate breakpoint crossings are reconciled independently',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          when(mockResponsiveUtils.isMatchedDesktopWidth(any)).thenAnswer(
            (invocation) =>
                (invocation.positionalArguments.first as double) >= 1200,
          );
          when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.emailsInCurrentMailbox)
              .thenReturn(RxList([]));
          when(mockSearchController.isSearchEmailRunning).thenReturn(false);
          final coordinator = createSearchLayoutCoordinatorForTest();
          coordinator.handleBrowserWidthChange(900);
          await tester.pump();
          clearInteractions(mockMailboxDashBoardController);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          coordinator.handleBrowserWidthChange(1200);
          await tester.pump();
          when(mockSearchController.isSearchEmailRunning).thenReturn(false);
          coordinator.handleBrowserWidthChange(900);
          await tester.pump();
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          coordinator.handleBrowserWidthChange(1200);
          await tester.pump();

          verify(
            mockMailboxDashBoardController.dispatchRoute(
              DashboardRoutes.thread,
            ),
          ).called(2);
        },
      );
    });

    group('restore mailbox list after responsive search handoff:', () {
      testWidgets(
        'desktop search ownership is replaced with the selected mailbox list',
        (tester) async {
          PlatformInfo.isTestingForWeb = true;
          await tester.pumpWidget(
            const GetMaterialApp(home: SizedBox.shrink()),
          );
          PlatformInfo.isTestingForWeb = false;
          final controllerUnderTest = ThreadController(
            mockGetEmailsInMailboxInteractor,
            mockRefreshChangesEmailsInMailboxInteractor,
            mockLoadMoreEmailsInMailboxInteractor,
            mockGetEmailByIdInteractor,
            mockCleanAndGetEmailsInMailboxInteractor,
          );
          addTearDown(() {
            PlatformInfo.isTestingForWeb = false;
            controllerUnderTest.onClose();
          });
          final mailboxId = MailboxId(Id('inbox'));
          final mailbox = PresentationMailbox(
            mailboxId,
            role: PresentationMailbox.roleInbox,
          );
          final searchEmail = PresentationEmail(
            id: EmailId(Id('search-email')),
          );
          final mailboxEmail = PresentationEmail(
            id: EmailId(Id('mailbox-email')),
            mailboxIds: {mailboxId: true},
          );
          final displayedEmails = <PresentationEmail>[searchEmail].obs;
          when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockMailboxDashBoardController.emailsInCurrentMailbox)
              .thenReturn(displayedEmails);
          when(mockMailboxDashBoardController.listEmailSelected)
              .thenReturn(RxList([]));
          when(mockMailboxDashBoardController.currentSelectMode)
              .thenReturn(Rx(SelectMode.INACTIVE));
          when(mockMailboxDashBoardController.accountId)
              .thenReturn(Rxn(AccountFixtures.aliceAccountId));
          when(mockMailboxDashBoardController.sessionCurrent)
              .thenReturn(SessionFixtures.aliceSession);
          when(mockMailboxDashBoardController.selectedMailbox)
              .thenReturn(Rxn(mailbox));
          when(mockMailboxDashBoardController.filterMessageOption)
              .thenReturn(Rx(FilterMessageOption.all));
          when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
          when(mockMailboxDashBoardController.isSelectionEnabled())
              .thenReturn(false);
          when(mockMailboxDashBoardController.updateEmailList(any)).thenAnswer(
            (invocation) => displayedEmails.assignAll(
              invocation.positionalArguments.first as List<PresentationEmail>,
            ),
          );
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);
          when(mockSearchController.searchQuery).thenReturn(null);
          when(mockGetEmailsInMailboxInteractor.execute(
            any,
            any,
            limit: anyNamed('limit'),
            sort: anyNamed('sort'),
            emailFilter: anyNamed('emailFilter'),
            propertiesCreated: anyNamed('propertiesCreated'),
            propertiesUpdated: anyNamed('propertiesUpdated'),
            getLatestChanges: anyNamed('getLatestChanges'),
            useCache: anyNamed('useCache'),
            forceEmailQuery: anyNamed('forceEmailQuery'),
            collapseThreads: anyNamed('collapseThreads'),
          )).thenAnswer(
            (_) => Stream.value(Right(GetAllEmailSuccess(
              emailList: [mailboxEmail],
              currentMailboxId: mailboxId,
            ))),
          );
          clearInteractions(mockGetEmailsInMailboxInteractor);

          ThreadSearchExecutionObserver(controllerUnderTest)
              .onNewSearchStarted();
          expect(displayedEmails, isEmpty);
          when(mockSearchController.isSearchEmailRunning).thenReturn(false);

          controllerUnderTest.restoreMailboxEmailListAfterSearch();
          await tester.pump();

          expect(displayedEmails, [mailboxEmail]);
          verify(mockGetEmailsInMailboxInteractor.execute(
            any,
            any,
            limit: anyNamed('limit'),
            sort: anyNamed('sort'),
            emailFilter: anyNamed('emailFilter'),
            propertiesCreated: anyNamed('propertiesCreated'),
            propertiesUpdated: anyNamed('propertiesUpdated'),
            getLatestChanges: false,
            useCache: anyNamed('useCache'),
            forceEmailQuery: anyNamed('forceEmailQuery'),
            collapseThreads: anyNamed('collapseThreads'),
          )).called(1);

          final nextPage = List.generate(
            ThreadConstants.maxCountEmails,
            (index) => PresentationEmail(
              id: EmailId(Id('mailbox-more-$index')),
              mailboxIds: {mailboxId: true},
            ),
          );
          PlatformInfo.isTestingForWeb = false;
          controllerUnderTest.handleSuccessViewState(
            LoadMoreEmailsSuccess(
              nextPage,
              serverEmailCount: ThreadConstants.maxCountEmails,
            ),
          );

          expect(controllerUnderTest.canLoadMore, isTrue);
          expect(
            displayedEmails,
            containsAll(nextPage),
          );
        },
      );

      test('mobile-only search does not reload the mailbox list', () {
        final controllerUnderTest = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
        );
        addTearDown(controllerUnderTest.onClose);
        clearInteractions(mockGetEmailsInMailboxInteractor);

        controllerUnderTest.restoreMailboxEmailListAfterSearch();

        verifyNever(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        ));
      });

      test(
        'mobile handoff skips routing when SearchEmailController cannot be resolved',
        () {
          when(mockMailboxDashBoardController.searchController)
              .thenReturn(mockSearchController);
          when(mockSearchController.isSearchEmailRunning).thenReturn(true);

          final coordinator = createSearchLayoutCoordinatorForTest();

          expect(
            () => coordinator.reconcile(false),
            returnsNormally,
          );
          verifyNever(mockMailboxDashBoardController.dispatchRoute(any));
        },
      );
    });

    group('ThreadSearchExecutionObserver ownership guard test:', () {
      final mailboxId = MailboxId(Id('inbox'));
      late ThreadSearchExecutionObserver observer;

      setUp(() {
        observer = ThreadSearchExecutionObserver(threadController);
        clearInteractions(mockMailboxDashBoardController);
      });

      tearDown(() => reset(mockResponsiveUtils));

      testWidgets(
        'GIVEN the layout is not web desktop (small screen) '
        'WHEN a search result is dispatched by the executor '
        'THEN the thread SHOULD ignore it — no mutation of the off-screen list',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(false);

        observer.onSearchResult(
          const SearchEmailResult(emails: [], canLoadMore: false),
          isFreshResult: true,
        );

        verifyNever(mockMailboxDashBoardController.updateEmailList(any));
        verifyNever(
          mockMailboxDashBoardController.updateRefreshAllEmailState(any),
        );
      });

      testWidgets(
        'GIVEN desktop owns a replayed search failure '
        'THEN it hydrates failure state without repeating the toast',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        clearInteractions(mockAppToast);

        observer.onSearchFailure(
          Exception('search failed'),
          isReplay: true,
        );

        verify(
          mockMailboxDashBoardController.updateRefreshAllEmailState(any),
        ).called(1);
        verifyNever(mockAppToast.showToastMessageWithMultipleActions(
          any,
          any,
          actions: anyNamed('actions'),
          textColor: anyNamed('textColor'),
          backgroundColor: anyNamed('backgroundColor'),
          infinityToast: anyNamed('infinityToast'),
        ));
      });

      testWidgets(
        'GIVEN the layout is not web desktop (small screen) '
        'WHEN a search failure is dispatched by the executor '
        'THEN the thread SHOULD ignore it — no duplicate failure state/toast',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(false);

        observer.onSearchFailure(Exception('search failed'));

        verifyNever(
          mockMailboxDashBoardController.updateRefreshAllEmailState(any),
        );
      });

      testWidgets(
        'GIVEN the layout IS web desktop (inline search, incl. threadDetailed) '
        'WHEN a search result is dispatched by the executor '
        'THEN the thread SHOULD apply it to the mailbox list',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(false);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        observer.onSearchResult(
          const SearchEmailResult(emails: [], canLoadMore: false),
          isFreshResult: true,
        );

        verify(mockMailboxDashBoardController.updateEmailList(any)).called(1);
      });

      testWidgets(
        'GIVEN the layout IS web desktop and a search is loading '
        'WHEN the executor delivers the result '
        'THEN viewState SHOULD leave SearchingState so the loading bar stops',
      (tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        when(mockResponsiveUtils.isWebDesktop(any)).thenReturn(true);
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(false);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        observer.onSearchLoading();
        expect(
          threadController.viewState.value.getOrElse(() => UIState.idle),
          isA<SearchingState>(),
        );

        observer.onSearchResult(
          const SearchEmailResult(emails: [], canLoadMore: false),
          isFreshResult: true,
        );

        expect(
          threadController.viewState.value.getOrElse(() => UIState.idle),
          isA<SearchEmailSuccess>(),
        );
      });
    });

    group('shouldAutoLoadMoreByEstimatedHeight unit test:', () {
      test(
        'GIVEN totalHeight is 0 (empty list) '
        'WHEN no emails are loaded '
        'THEN SHOULD return false — nothing to trigger load from',
      () {
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByEstimatedHeight(0, 816),
          isFalse,
        );
      });

      test(
        'GIVEN totalHeight is less than viewportHeight '
        'WHEN content does not fill the viewport '
        'THEN SHOULD return true',
      () {
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByEstimatedHeight(800, 816),
          isTrue,
        );
      });

      test(
        'GIVEN totalHeight equals viewportHeight '
        'WHEN estimated height exactly fills the viewport '
        'THEN SHOULD return false — actual rendered height likely already overflows',
      () {
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByEstimatedHeight(816, 816),
          isFalse,
        );
      });

      test(
        'GIVEN totalHeight exceeds viewportHeight '
        'WHEN content overflows the viewport '
        'THEN SHOULD return false',
      () {
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByEstimatedHeight(1200, 816),
          isFalse,
        );
      });

      test(
        'GIVEN 20 emails × 40px estimate = 800px with viewport 816px '
        'WHEN actual rendered height is likely larger (e.g. 70px/email = 1400px) '
        'THEN SHOULD return true — one extra load may occur but no infinite loop',
      () {
        const estimatedHeight =
            20 * ThreadConstants.defaultMaxHeightEmailItemOnBrowser;
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByEstimatedHeight(estimatedHeight, 816),
          isTrue,
        );
      });

      test(
        'GIVEN 21 emails × 40px estimate = 840px with viewport 816px '
        'WHEN estimated height exceeds viewport on large-screen browser '
        'THEN SHOULD return false to prevent infinite load-more loop',
      () {
        const estimatedHeight =
            21 * ThreadConstants.defaultMaxHeightEmailItemOnBrowser;
        expect(
          AutoLoadMorePolicy.shouldAutoLoadMoreByEstimatedHeight(estimatedHeight, 816),
          isFalse,
        );
      });
    });
  });
}
