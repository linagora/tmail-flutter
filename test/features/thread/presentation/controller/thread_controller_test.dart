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
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/clean_and_get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/auto_load_more_policy.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
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

    threadController = ThreadController(
      mockGetEmailsInMailboxInteractor,
      mockRefreshChangesEmailsInMailboxInteractor,
      mockLoadMoreEmailsInMailboxInteractor,
      mockSearchEmailInteractor,
      mockSearchMoreEmailInteractor,
      mockGetEmailByIdInteractor,
      mockCleanAndGetEmailsInMailboxInteractor,
    );
  });

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

    group('_refreshEmailChanges::test', () {
      late ThreadController refreshChangesController;

      setUp(() {
        refreshChangesController = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockSearchEmailInteractor,
          mockSearchMoreEmailInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
        );
      });

      tearDown(() {
        refreshChangesController.onClose();
      });

      test(
        'WHEN thread controller in searching\n'
        'AND `MarkAsStarEmailSuccess` is coming\n'
        'THEN `SearchEmailInteractor` is invoked with proper arguments\n'
        'AND `listEmailController` should not jumped\n'
        'AND `mailboxDashBoardController.emailsInCurrentMailbox` should not be cleared',
      () async {
        // Arrange
        PlatformInfo.isTestingForWeb = true;
        final emailList = [
          PresentationEmail(
            id: EmailId(Id('email1')),
            subject: 'hello',
            keywords: {KeyWordIdentifier.emailFlagged: true}),
          PresentationEmail(
            id: EmailId(Id('email2')),
            subject: 'hello')
        ];

        when(mockMailboxDashBoardController.sessionCurrent).thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(SearchEmailSuccess(emailList))));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList(emailList));
        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.emailUIAction).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.filterMessageOption).thenReturn(Rx(FilterMessageOption.all));
        when(mockMailboxDashBoardController.currentEmailState).thenReturn(State('old-state'));
        when(mockSearchController.searchState).thenReturn(Rx(SearchState.initial()));
        when(mockSearchController.isAdvancedSearchViewOpen).thenReturn(RxBool(false));
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        when(mockSearchController.searchEmailFilter).thenReturn(Rx(SearchEmailFilter.initial()));
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
        )).thenAnswer((_) => Stream.value(Right(RefreshChangesAllEmailSuccess(
          emailList: emailList,
          currentEmailState: State('old-state'))))
        );

        // Act
        refreshChangesController.onInit();
        mockMailboxDashBoardController.emailsInCurrentMailbox.refresh();

        mockMailboxDashBoardController.emailUIAction.value =
            RefreshChangeEmailAction(newState: State('new-state'));

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

        // Assert
        verify(mockSearchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: UnsignedInt(emailList.length),
          position: null,
          sort: SearchEmailFilter.defaultSortOrder.getSortOrder().toNullable(),
          filter: SearchEmailFilter.initial().mappingToEmailFilterCondition(),
          collapseThreads: false,
          properties: EmailUtils.getPropertiesForEmailGetMethod(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId),
          needRefreshSearchState: true
        )).called(1);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.isNotEmpty, isTrue);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.length, emailList.length);
        expect(refreshChangesController.isListEmailScrollViewJumping, isFalse);
        PlatformInfo.isTestingForWeb = false;
      });

      test(
        'WHEN thread controller in searching\n'
        'AND `StartSearchEmailAction` is coming\n'
        'THEN `SearchEmailInteractor` is invoked with proper arguments\n'
        'AND `listEmailController` should jumped\n'
        'AND `mailboxDashBoardController.emailsInCurrentMailbox` should be cleared',
      () async {
        // Arrange
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
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(SearchEmailSuccess(emailList))));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox).thenReturn(RxList(emailList));
        when(mockMailboxDashBoardController.selectedMailbox).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.emailUIAction).thenReturn(Rxn(null));
        when(mockMailboxDashBoardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.filterMessageOption).thenReturn(Rx(FilterMessageOption.all));
        when(mockMailboxDashBoardController.currentSelectMode).thenReturn(Rx(SelectMode.INACTIVE));
        when(mockMailboxDashBoardController.listEmailSelected).thenReturn(RxList([]));
        when(mockSearchController.searchState).thenReturn(Rx(SearchState.initial()));
        when(mockSearchController.isAdvancedSearchViewOpen).thenReturn(RxBool(false));
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        when(mockSearchController.searchEmailFilter).thenReturn(Rx(SearchEmailFilter.initial()));
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
        refreshChangesController.onInit();
        mockMailboxDashBoardController.dashBoardAction.value = StartSearchEmailAction();

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

        // Assert
        verify(mockSearchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: ThreadConstants.defaultLimit,
          position: null,
          sort: SearchEmailFilter.defaultSortOrder.getSortOrder().toNullable(),
          filter: SearchEmailFilter.initial().mappingToEmailFilterCondition(),
          collapseThreads: false,
          properties: EmailUtils.getPropertiesForEmailGetMethod(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId),
          needRefreshSearchState: false
        )).called(1);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.isEmpty, isTrue);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.length, equals(0));
      });
    });

    group('_registerObxStreamListener test:', () {
      late ThreadController obxListenerController;

      setUp(() {
        obxListenerController = ThreadController(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockSearchEmailInteractor,
          mockSearchMoreEmailInteractor,
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
        when(mockSearchController.searchState).thenReturn(SearchState(SearchStatus.INACTIVE).obs);

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
          mockSearchEmailInteractor,
          mockSearchMoreEmailInteractor,
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
        when(mockSearchController.searchState).thenReturn(SearchState(SearchStatus.INACTIVE).obs);

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
    });

    group('canLoadMore lifecycle & guard regression:', () {
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
        'THEN it routes to search-more, NOT load-more (canLoadMore is not consulted)',
      () {
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        threadController.canSearchMore = false;
        threadController.canLoadMore = true;

        threadController.handleLoadMoreEmailsRequest();

        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));
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
