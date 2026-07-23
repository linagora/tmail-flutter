
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_restored_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/restore_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/store_session_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/get_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/clear_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_stored_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_by_id_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/clean_and_get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_spam_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/account_fixtures.dart';
import '../../fixtures/session_fixtures.dart';
import 'verify_before_time_in_search_email_filter_test.mocks.dart';

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
  MockSpec<GetEmailsInMailboxInteractor>(),
  MockSpec<RefreshChangesEmailsInMailboxInteractor>(),
  MockSpec<LoadMoreEmailsInMailboxInteractor>(),
  MockSpec<SearchEmailInteractor>(),
  MockSpec<SearchMoreEmailInteractor>(),
  MockSpec<GetEmailByIdInteractor>(),
  // Search controller mock specs
  MockSpec<QuickSearchEmailInteractor>(),
  MockSpec<SaveRecentSearchInteractor>(),
  MockSpec<GetAllRecentSearchLatestInteractor>(),
  // MailboxDashboard controller mock specs
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),
  MockSpec<GetOidcUserInfoInteractor>(),
  MockSpec<EmailReceiveManager>(),
  MockSpec<DownloadController>(fallbackGenerators: fallbackGenerators),
  MockSpec<AppGridDashboardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<SpamReportController>(fallbackGenerators: fallbackGenerators),
  MockSpec<LabelController>(fallbackGenerators: fallbackGenerators),
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<RemoveEmailDraftsInteractor>(),
  MockSpec<MoveToMailboxInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<DeleteEmailPermanentlyInteractor>(),
  MockSpec<MarkAsMailboxReadInteractor>(),
  MockSpec<GetAllComposerCacheInteractor>(),
  MockSpec<MarkAsMultipleEmailReadInteractor>(),
  MockSpec<MarkAsStarMultipleEmailInteractor>(),
  MockSpec<MoveMultipleEmailToMailboxInteractor>(),
  MockSpec<DeleteMultipleEmailsPermanentlyInteractor>(),
  MockSpec<SendEmailInteractor>(),
  MockSpec<StoreSendingEmailInteractor>(),
  MockSpec<UpdateSendingEmailInteractor>(),
  MockSpec<GetAllSendingEmailInteractor>(),
  MockSpec<StoreSessionInteractor>(),
  MockSpec<EmptySpamFolderInteractor>(),
  MockSpec<DeleteSendingEmailInteractor>(),
  MockSpec<UnsubscribeEmailInteractor>(),
  MockSpec<RestoredDeletedMessageInteractor>(),
  MockSpec<GetRestoredDeletedMessageInterator>(),
  MockSpec<GetIdentityCacheOnWebInteractor>(),
  MockSpec<RemoveAllComposerCacheInteractor>(),
  MockSpec<RemoveComposerCacheByIdInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<ComposerManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<CleanAndGetEmailsInMailboxInteractor>(),
  MockSpec<ClearMailboxInteractor>(),
  MockSpec<GetAuthenticationInfoInteractor>(),
  MockSpec<GetStoredOidcConfigurationInteractor>(),
  MockSpec<GetTokenOIDCInteractor>(),
  MockSpec<StoreEmailSortOrderInteractor>(),
  MockSpec<GetStoredEmailSortOrderInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declaration thread controller
  late ThreadController threadController;
  late MockGetEmailsInMailboxInteractor mockGetEmailsInMailboxInteractor;
  late MockRefreshChangesEmailsInMailboxInteractor mockRefreshChangesEmailsInMailboxInteractor;
  late MockLoadMoreEmailsInMailboxInteractor mockLoadMoreEmailsInMailboxInteractor;
  late MockSearchEmailInteractor mockSearchEmailInteractor;
  late MockSearchMoreEmailInteractor mockSearchMoreEmailInteractor;
  late MockGetEmailByIdInteractor mockGetEmailByIdInteractor;
  late MockCleanAndGetEmailsInMailboxInteractor mockCleanAndGetEmailsInMailboxInteractor;

  // Declaration search controller
  late SearchController searchController;
  late MockQuickSearchEmailInteractor mockQuickSearchEmailInteractor;
  late MockSaveRecentSearchInteractor mockSaveRecentSearchInteractor;
  late MockGetAllRecentSearchLatestInteractor mockGetAllRecentSearchLatestInteractor;
  late MockStoreEmailSortOrderInteractor mockStoreEmailSortOrderInteractor;
  late MockGetStoredEmailSortOrderInteractor mockGetStoredEmailSortOrderInteractor;

  // Declaration mailbox dashboard controller
  final MockGetSessionInteractor getSessionInteractor = MockGetSessionInteractor();
  final MockGetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
  final MockUpdateAccountCacheInteractor updateAccountCacheInteractor = MockUpdateAccountCacheInteractor();
  final MockGetOidcUserInfoInteractor getOidcUserInfoInteractor = MockGetOidcUserInfoInteractor();
  final MockRemoveEmailDraftsInteractor removeEmailDraftsInteractor = MockRemoveEmailDraftsInteractor();
  final MockEmailReceiveManager emailReceiveManager = MockEmailReceiveManager();
  final MockDownloadController downloadController = MockDownloadController();
  final MockAppGridDashboardController appGridDashboardController = MockAppGridDashboardController();
  final MockSpamReportController spamReportController = MockSpamReportController();
  final MockLabelController labelController = MockLabelController();
  final MockNetworkConnectionController networkConnectionController = MockNetworkConnectionController();
  final composerManager = MockComposerManager();

  late MailboxDashBoardController mailboxDashboardController;
  late MockMoveToMailboxInteractor moveToMailboxInteractor;
  late MockDeleteEmailPermanentlyInteractor deleteEmailPermanentlyInteractor;
  late MockMarkAsMailboxReadInteractor markAsMailboxReadInteractor;
  late MockGetAllComposerCacheInteractor getAllComposerCacheInteractor;
  late MockGetIdentityCacheOnWebInteractor getIdentityCacheOnWebInteractor;
  late MockMarkAsEmailReadInteractor markAsEmailReadInteractor;
  late MockMarkAsStarEmailInteractor markAsStarEmailInteractor;
  late MockMarkAsMultipleEmailReadInteractor markAsMultipleEmailReadInteractor;
  late MockMarkAsStarMultipleEmailInteractor markAsStarMultipleEmailInteractor;
  late MockMoveMultipleEmailToMailboxInteractor moveMultipleEmailToMailboxInteractor;
  late MockDeleteMultipleEmailsPermanentlyInteractor deleteMultipleEmailsPermanentlyInteractor;
  late MockSendEmailInteractor sendEmailInteractor;
  late MockStoreSendingEmailInteractor storeSendingEmailInteractor;
  late MockUpdateSendingEmailInteractor updateSendingEmailInteractor;
  late MockGetAllSendingEmailInteractor getAllSendingEmailInteractor;
  late MockStoreSessionInteractor storeSessionInteractor;
  late MockEmptySpamFolderInteractor emptySpamFolderInteractor;
  late MockDeleteSendingEmailInteractor deleteSendingEmailInteractor;
  late MockUnsubscribeEmailInteractor unsubscribeEmailInteractor;
  late MockRestoredDeletedMessageInteractor restoreDeletedMessageInteractor;
  late MockGetRestoredDeletedMessageInterator getRestoredDeletedMessageInteractor;
  late MockRemoveAllComposerCacheInteractor removeAllComposerCacheInteractor;
  late MockRemoveComposerCacheByIdInteractor removeComposerCacheByIdOnWebInteractor;
  late MockGetAllIdentitiesInteractor getAllIdentitiesInteractor;
  late MockClearMailboxInteractor clearMailboxInteractor;
  late MockGetAuthenticationInfoInteractor getAuthenticationInfoInteractor;
  late MockGetStoredOidcConfigurationInteractor getStoredOidcConfigurationInteractor;
  late MockGetTokenOIDCInteractor getTokenOIDCInteractor;

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
    mockGetEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
    mockRefreshChangesEmailsInMailboxInteractor = MockRefreshChangesEmailsInMailboxInteractor();
    mockLoadMoreEmailsInMailboxInteractor = MockLoadMoreEmailsInMailboxInteractor();
    mockSearchEmailInteractor = MockSearchEmailInteractor();
    mockSearchMoreEmailInteractor = MockSearchMoreEmailInteractor();
    mockGetEmailByIdInteractor = MockGetEmailByIdInteractor();
    mockCleanAndGetEmailsInMailboxInteractor = MockCleanAndGetEmailsInMailboxInteractor();

    // Mock search controller
    mockQuickSearchEmailInteractor = MockQuickSearchEmailInteractor();
    mockSaveRecentSearchInteractor = MockSaveRecentSearchInteractor();
    mockGetAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();
    mockStoreEmailSortOrderInteractor = MockStoreEmailSortOrderInteractor();
    mockGetStoredEmailSortOrderInteractor = MockGetStoredEmailSortOrderInteractor();

    // Mock dashboard controller
    moveToMailboxInteractor = MockMoveToMailboxInteractor();
    deleteEmailPermanentlyInteractor = MockDeleteEmailPermanentlyInteractor();
    markAsMailboxReadInteractor = MockMarkAsMailboxReadInteractor();
    getAllComposerCacheInteractor = MockGetAllComposerCacheInteractor();
    getIdentityCacheOnWebInteractor = MockGetIdentityCacheOnWebInteractor();
    markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
    markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
    markAsMultipleEmailReadInteractor = MockMarkAsMultipleEmailReadInteractor();
    markAsStarMultipleEmailInteractor = MockMarkAsStarMultipleEmailInteractor();
    moveMultipleEmailToMailboxInteractor = MockMoveMultipleEmailToMailboxInteractor();
    deleteMultipleEmailsPermanentlyInteractor = MockDeleteMultipleEmailsPermanentlyInteractor();
    sendEmailInteractor = MockSendEmailInteractor();
    storeSendingEmailInteractor = MockStoreSendingEmailInteractor();
    updateSendingEmailInteractor = MockUpdateSendingEmailInteractor();
    getAllSendingEmailInteractor = MockGetAllSendingEmailInteractor();
    storeSessionInteractor = MockStoreSessionInteractor();
    emptySpamFolderInteractor = MockEmptySpamFolderInteractor();
    deleteSendingEmailInteractor = MockDeleteSendingEmailInteractor();
    unsubscribeEmailInteractor = MockUnsubscribeEmailInteractor();
    restoreDeletedMessageInteractor = MockRestoredDeletedMessageInteractor();
    getRestoredDeletedMessageInteractor = MockGetRestoredDeletedMessageInterator();
    removeAllComposerCacheInteractor = MockRemoveAllComposerCacheInteractor();
    removeComposerCacheByIdOnWebInteractor = MockRemoveComposerCacheByIdInteractor();
    getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
    clearMailboxInteractor = MockClearMailboxInteractor();
    getAuthenticationInfoInteractor = MockGetAuthenticationInfoInteractor();
    getStoredOidcConfigurationInteractor = MockGetStoredOidcConfigurationInteractor();
    getTokenOIDCInteractor = MockGetTokenOIDCInteractor();

    searchController = SearchController(
      mockQuickSearchEmailInteractor,
      mockSaveRecentSearchInteractor,
      mockGetAllRecentSearchLatestInteractor,
    );
    Get.put<SearchController>(searchController);

    Get.put<RemoveEmailDraftsInteractor>(removeEmailDraftsInteractor);
    Get.put<EmailReceiveManager>(emailReceiveManager);
    Get.put<DownloadController>(downloadController);
    Get.put<AppGridDashboardController>(appGridDashboardController);
    Get.put<SpamReportController>(spamReportController);
    Get.put<LabelController>(labelController);
    Get.put<NetworkConnectionController>(networkConnectionController);
    Get.put<GetSessionInteractor>(getSessionInteractor);
    Get.put<GetAuthenticatedAccountInteractor>(getAuthenticatedAccountInteractor);
    Get.put<UpdateAccountCacheInteractor>(updateAccountCacheInteractor);
    Get.put<GetOidcUserInfoInteractor>(getOidcUserInfoInteractor);
    Get.put<ComposerManager>(composerManager);
    Get.put<GetAuthenticationInfoInteractor>(getAuthenticationInfoInteractor);
    Get.put<GetStoredOidcConfigurationInteractor>(getStoredOidcConfigurationInteractor);
    Get.put<GetTokenOIDCInteractor>(getTokenOIDCInteractor);

    mailboxDashboardController = MailboxDashBoardController(
      moveToMailboxInteractor,
      deleteEmailPermanentlyInteractor,
      markAsMailboxReadInteractor,
      getAllComposerCacheInteractor,
      getIdentityCacheOnWebInteractor,
      markAsEmailReadInteractor,
      markAsStarEmailInteractor,
      markAsMultipleEmailReadInteractor,
      markAsStarMultipleEmailInteractor,
      moveMultipleEmailToMailboxInteractor,
      deleteMultipleEmailsPermanentlyInteractor,
      mockGetEmailByIdInteractor,
      sendEmailInteractor,
      storeSendingEmailInteractor,
      updateSendingEmailInteractor,
      getAllSendingEmailInteractor,
      storeSessionInteractor,
      emptySpamFolderInteractor,
      deleteSendingEmailInteractor,
      unsubscribeEmailInteractor,
      restoreDeletedMessageInteractor,
      getRestoredDeletedMessageInteractor,
      removeAllComposerCacheInteractor,
      removeComposerCacheByIdOnWebInteractor,
      getAllIdentitiesInteractor,
      clearMailboxInteractor,
      mockStoreEmailSortOrderInteractor,
      mockGetStoredEmailSortOrderInteractor,
    );

    when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
    when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
    final isLabelSettingEnabled = RxBool(false);
    when(labelController.isLabelSettingEnabled).thenReturn(isLabelSettingEnabled);

    Get.put<MailboxDashBoardController>(mailboxDashboardController);

    Get.put<SearchEmailInteractor>(mockSearchEmailInteractor);
    Get.put<SearchMoreEmailInteractor>(mockSearchMoreEmailInteractor);
    threadController = ThreadController(
      mockGetEmailsInMailboxInteractor,
      mockRefreshChangesEmailsInMailboxInteractor,
      mockLoadMoreEmailsInMailboxInteractor,
      mockGetEmailByIdInteractor,
      mockCleanAndGetEmailsInMailboxInteractor,
    );
    threadController.onInit();

    mailboxDashboardController.sessionCurrent = SessionFixtures.aliceSession;
    mailboxDashboardController.filterMessageOption.value = FilterMessageOption.all;
    mailboxDashboardController.accountId.value = AccountFixtures.aliceAccountId;

    mailboxDashboardController.onInit();
  });

  group('SearchController::updateSortOrderFilter', () {
    setUp(() {
      appProviderContainer.read(searchFilterProvider.notifier).set(SearchEmailFilter.initial());
    });

    test(
      'SHOULD preserve startDate and endDate '
      'WHEN sort order changes on any filter',
    () {
      // Arrange: snapshotted date bounds set when last7Days was selected
      // (last7Days.toDateRange() snapshots both bounds, so seed endDate too)
      final snapshotStart = UTCDate(DateTime.parse('2026-01-10T00:00:00.000Z'));
      final snapshotEnd = UTCDate(DateTime.parse('2026-01-17T00:00:00.000Z'));
      searchController.updateFilterEmail(
        sortOrderTypeOption: const Some(EmailSortOrderType.oldest),
        emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.last7Days),
        startDateOption: Some(snapshotStart),
        endDateOption: Some(snapshotEnd),
      );

      // Act
      searchController.updateSortOrderFilter(EmailSortOrderType.mostRecent);

      // Assert: user date bounds are preserved
      final filter = searchController.committedSearchFilter;
      expect(filter.sortOrderType, equals(EmailSortOrderType.mostRecent));
      expect(filter.startDate, equals(snapshotStart));
      expect(filter.endDate, equals(snapshotEnd));
      expect(filter.before, isNull);
      expect(filter.after, isNull);
      expect(filter.position, isNull);
    });

    test(
      'SHOULD preserve startDate and endDate '
      'WHEN sort order changes on a customRange filter',
    () {
      // Arrange: user has a custom date range applied
      final start = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
      final end = UTCDate(DateTime.parse('2026-03-31T23:59:59.000Z'));
      searchController.updateFilterEmail(
        sortOrderTypeOption: const Some(EmailSortOrderType.oldest),
        emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.customRange),
        startDateOption: Some(start),
        endDateOption: Some(end),
      );

      // Act
      searchController.updateSortOrderFilter(EmailSortOrderType.mostRecent);

      // Assert
      final filter = searchController.committedSearchFilter;
      expect(filter.sortOrderType, equals(EmailSortOrderType.mostRecent));
      expect(filter.startDate, equals(start));
      expect(filter.endDate, equals(end));
      expect(filter.before, isNull);
      expect(filter.after, isNull);
      expect(filter.position, isNull);
    });
  });
}
