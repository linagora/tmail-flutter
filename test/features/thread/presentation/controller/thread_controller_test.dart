import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart' hide State;
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
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
  MockSpec<ApplicationManager>(),
  MockSpec<ToastManager>(),
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
  late MockApplicationManager mockApplicationManager;
  late MockToastManager mockToastManager;

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
    mockApplicationManager = MockApplicationManager();
    mockToastManager = MockToastManager();

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
    Get.put<ApplicationManager>(mockApplicationManager);
    Get.put<ToastManager>(mockToastManager);

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

    Get.put<NetworkConnectionController>(mockNetworkConnectionController);
    Get.put<SearchController>(mockSearchController);
    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);

    threadController = ThreadController(
      mockGetEmailsInMailboxInteractor,
      mockRefreshChangesEmailsInMailboxInteractor,
      mockLoadMoreEmailsInMailboxInteractor,
      mockSearchEmailInteractor,
      mockSearchMoreEmailInteractor,
      mockGetEmailByIdInteractor);
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
      test(
        'WHEN thread controller in searching\n'
        'AND `MarkAsStarEmailSuccess` is coming\n'
        'THEN `SearchEmailInteractor` is invoked with proper arguments\n'
        'AND `listEmailController` should not jumped\n'
        'AND `mailboxDashBoardController.emailsInCurrentMailbox` should not be cleared',
      () async {
        // Arrange
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
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

        // Act
        threadController.onInit();

        mockMailboxDashBoardController.emailUIAction.value =
            RefreshChangeEmailAction(State('new-state'));

        await untilCalled(mockSearchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort:anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        ));

        // Assert
        verify(mockSearchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: UnsignedInt(emailList.length),
          position: null,
          sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
          filter: SearchEmailFilter.initial().mappingToEmailFilterCondition(),
          properties: EmailUtils.getPropertiesForEmailGetMethod(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId),
          needRefreshSearchState: true
        )).called(1);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.isNotEmpty, isTrue);
        expect(mockMailboxDashBoardController.emailsInCurrentMailbox.length, emailList.length);
        expect(threadController.isListEmailScrollViewJumping, isFalse);
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
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

        // Act
        threadController.onInit();
        mockMailboxDashBoardController.dashBoardAction.value = StartSearchEmailAction();

        await untilCalled(mockSearchEmailInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          position: anyNamed('position'),
          sort:anyNamed('sort'),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
          needRefreshSearchState: anyNamed('needRefreshSearchState'),
        ));

        // Assert
        verify(mockSearchEmailInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: ThreadConstants.defaultLimit,
          position: null,
          sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
          filter: SearchEmailFilter.initial().mappingToEmailFilterCondition(),
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
        threadController.onInit();
        mockMailboxDashBoardController.selectedMailbox.value = mailboxAfter;
        await untilCalled(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
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
          getLatestChanges: false,
        ));
      });
    });
  });
}