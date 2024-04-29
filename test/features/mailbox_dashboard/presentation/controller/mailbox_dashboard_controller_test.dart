import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter/widgets.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:rxdart/subjects.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
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
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/empty_folder_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/invalid_mail_format_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_default_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subaddressing_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/download/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_spam_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_all_as_unread_selection_all_emails_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_all_selection_all_emails_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
    if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'mailbox_dashboard_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  // write mock specs for unavailable dependencies
  MockSpec<MoveToMailboxInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<DeleteEmailPermanentlyInteractor>(),
  MockSpec<MarkAsMailboxReadInteractor>(),
  MockSpec<GetComposerCacheOnWebInteractor>(),
  MockSpec<MarkAsMultipleEmailReadInteractor>(),
  MockSpec<MarkAsStarMultipleEmailInteractor>(),
  MockSpec<MoveMultipleEmailToMailboxInteractor>(),
  MockSpec<EmptyTrashFolderInteractor>(),
  MockSpec<DeleteMultipleEmailsPermanentlyInteractor>(),
  MockSpec<GetEmailByIdInteractor>(),
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
  MockSpec<BuildContext>(),
  MockSpec<RemoveEmailDraftsInteractor>(),
  MockSpec<EmailReceiveManager>(),
  MockSpec<DownloadController>(fallbackGenerators: fallbackGenerators),
  MockSpec<AppGridDashboardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<SpamReportController>(fallbackGenerators: fallbackGenerators),
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<QuickSearchEmailInteractor>(),
  MockSpec<SaveRecentSearchInteractor>(),
  MockSpec<GetAllRecentSearchLatestInteractor>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),
  MockSpec<CreateNewMailboxInteractor>(),
  MockSpec<DeleteMultipleMailboxInteractor>(),
  MockSpec<RenameMailboxInteractor>(),
  MockSpec<MoveMailboxInteractor>(),
  MockSpec<SubscribeMailboxInteractor>(),
  MockSpec<SubscribeMultipleMailboxInteractor>(),
  MockSpec<SubaddressingInteractor>(),
  MockSpec<CreateDefaultMailboxInteractor>(),
  MockSpec<TreeBuilder>(),
  MockSpec<VerifyNameInteractor>(),
  MockSpec<GetAllMailboxInteractor>(),
  MockSpec<RefreshAllMailboxInteractor>(),
  MockSpec<GetEmailsInMailboxInteractor>(),
  MockSpec<RefreshChangesEmailsInMailboxInteractor>(),
  MockSpec<LoadMoreEmailsInMailboxInteractor>(),
  MockSpec<SearchEmailInteractor>(),
  MockSpec<SearchMoreEmailInteractor>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<RemoveComposerCacheOnWebInteractor>(),
  MockSpec<ApplicationManager>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<GetIdentityCacheOnWebInteractor>(),
  MockSpec<MarkAllAsUnreadSelectionAllEmailsInteractor>(),
  MockSpec<MoveAllSelectionAllEmailsInteractor>(),
])
void main() {
  // mock mailbox dashboard controller direct dependencies
  final moveToMailboxInteractor = MockMoveToMailboxInteractor();
  final deleteEmailPermanentlyInteractor =
      MockDeleteEmailPermanentlyInteractor();
  final markAsMailboxReadInteractor = MockMarkAsMailboxReadInteractor();
  final getEmailCacheOnWebInteractor = MockGetComposerCacheOnWebInteractor();
  final getIdentityCacheOnWebInteractor = MockGetIdentityCacheOnWebInteractor();
  final markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
  final markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
  final markAsMultipleEmailReadInteractor =
      MockMarkAsMultipleEmailReadInteractor();
  final markAsStarMultipleEmailInteractor =
      MockMarkAsStarMultipleEmailInteractor();
  final moveMultipleEmailToMailboxInteractor =
      MockMoveMultipleEmailToMailboxInteractor();
  final emptyTrashFolderInteractor = MockEmptyTrashFolderInteractor();
  final deleteMultipleEmailsPermanentlyInteractor =
      MockDeleteMultipleEmailsPermanentlyInteractor();
  final getEmailByIdInteractor = MockGetEmailByIdInteractor();
  final sendEmailInteractor = MockSendEmailInteractor();
  final storeSendingEmailInteractor = MockStoreSendingEmailInteractor();
  final updateSendingEmailInteractor = MockUpdateSendingEmailInteractor();
  final getAllSendingEmailInteractor = MockGetAllSendingEmailInteractor();
  final storeSessionInteractor = MockStoreSessionInteractor();
  final emptySpamFolderInteractor = MockEmptySpamFolderInteractor();
  final deleteSendingEmailInteractor = MockDeleteSendingEmailInteractor();
  final unsubscribeEmailInteractor = MockUnsubscribeEmailInteractor();
  final restoreDeletedMessageInteractor =
      MockRestoredDeletedMessageInteractor();
  final getRestoredDeletedMessageInteractor =
      MockGetRestoredDeletedMessageInterator();
  late MailboxDashBoardController mailboxDashboardController;

  // mock mailbox dashboard controller Get dependencies
  final removeEmailDraftsInteractor = MockRemoveEmailDraftsInteractor();
  final emailReceiveManager = MockEmailReceiveManager();
  final downloadController = MockDownloadController();
  final appGridDashboardController = MockAppGridDashboardController();
  final spamReportController = MockSpamReportController();
  final networkConnectionController = MockNetworkConnectionController();

  // mock search controller direct dependencies
  final quickSearchEmailInteractor = MockQuickSearchEmailInteractor();
  final saveRecentSearchInteractor = MockSaveRecentSearchInteractor();
  final getAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();
  late SearchController searchController;

  // mock base controller Get dependencies
  final cachingManager = MockCachingManager();
  final languageCacheManager = MockLanguageCacheManager();
  final authorizationInterceptors = MockAuthorizationInterceptors();
  final dynamicUrlInterceptors = MockDynamicUrlInterceptors();
  final deleteCredentialInteractor = MockDeleteCredentialInteractor();
  final logoutOidcInteractor = MockLogoutOidcInteractor();
  final deleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
  final appToast = MockAppToast();
  final imagePaths = MockImagePaths();
  final responsiveUtils = MockResponsiveUtils();
  final uuid = MockUuid();
  final applicationManager = MockApplicationManager();
  final mockToastManager = MockToastManager();
  final mockTwakeAppManager = MockTwakeAppManager();

  // mock reloadable controller Get dependencies
  final getSessionInteractor = MockGetSessionInteractor();
  final getAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
  final updateAccountCacheInteractor = MockUpdateAccountCacheInteractor();

  // mock mailbox controller direct dependencies
  final createNewMailboxInteractor = MockCreateNewMailboxInteractor();
  final deleteMultipleMailboxInteractor = MockDeleteMultipleMailboxInteractor();
  final renameMailboxInteractor = MockRenameMailboxInteractor();
  final moveMailboxInteractor = MockMoveMailboxInteractor();
  final subscribeMailboxInteractor = MockSubscribeMailboxInteractor();
  final subscribeMultipleMailboxInteractor = MockSubscribeMultipleMailboxInteractor();
  final subaddressingInteractor = MockSubaddressingInteractor();
  final createDefaultMailboxInteractor = MockCreateDefaultMailboxInteractor();
  final treeBuilder = MockTreeBuilder();
  final verifyNameInteractor = MockVerifyNameInteractor();
  final getAllMailboxInteractor = MockGetAllMailboxInteractor();
  final refreshAllMailboxInteractor = MockRefreshAllMailboxInteractor();
  final removeComposerCacheOnWebInteractor = MockRemoveComposerCacheOnWebInteractor();
  final getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
  final markAllAsUnreadSelectionAllEmailsInteractor = MockMarkAllAsUnreadSelectionAllEmailsInteractor();
  final moveAllSelectionAllEmailsInteractor = MockMoveAllSelectionAllEmailsInteractor();
  late MailboxController mailboxController;

  // mock thread controller direct dependencies
  late MockGetEmailsInMailboxInteractor getEmailsInMailboxInteractor;
  final refreshChangesEmailsInMailboxInteractor =
      MockRefreshChangesEmailsInMailboxInteractor();
  final loadMoreEmailsInMailboxInteractor = MockLoadMoreEmailsInMailboxInteractor();
  final searchEmailInteractor = MockSearchEmailInteractor();
  final searchMoreEmailInteractor = MockSearchMoreEmailInteractor();
  late ThreadController threadController;

  late AdvancedFilterController advancedFilterController;

  final context = MockBuildContext();
  const queryString = 'test text';
  final google = Uri.parse('https://www.google.com');
  final testSession =
      Session({}, {}, {}, UserName('data'), google, google, google, google, State('1'));
  final testMailboxId = MailboxId(Id('1'));
  final testAccountId = AccountId(Id('123'));

  setUp(() {
    Get.put<RemoveEmailDraftsInteractor>(removeEmailDraftsInteractor);
    Get.put<EmailReceiveManager>(emailReceiveManager);
    Get.put<DownloadController>(downloadController);
    Get.put<AppGridDashboardController>(appGridDashboardController);
    Get.put<SpamReportController>(spamReportController);
    Get.put<NetworkConnectionController>(networkConnectionController);
    Get.put<CachingManager>(cachingManager);
    Get.put<LanguageCacheManager>(languageCacheManager);
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(dynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(deleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(logoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(deleteAuthorityOidcInteractor);
    Get.put<AppToast>(appToast);
    Get.put<ImagePaths>(imagePaths);
    Get.put<ResponsiveUtils>(responsiveUtils);
    Get.put<Uuid>(uuid);
    Get.put<ApplicationManager>(applicationManager);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);
    Get.put<GetSessionInteractor>(getSessionInteractor);
    Get.put<GetAuthenticatedAccountInteractor>(getAuthenticatedAccountInteractor);
    Get.put<UpdateAccountCacheInteractor>(updateAccountCacheInteractor);
    Get.put<GetAllIdentitiesInteractor>(getAllIdentitiesInteractor);
    Get.put<RemoveComposerCacheOnWebInteractor>(removeComposerCacheOnWebInteractor);
    Get.put<MarkAllAsUnreadSelectionAllEmailsInteractor>(markAllAsUnreadSelectionAllEmailsInteractor);
    Get.put<MoveAllSelectionAllEmailsInteractor>(moveAllSelectionAllEmailsInteractor);

    searchController = SearchController(
      quickSearchEmailInteractor,
      saveRecentSearchInteractor,
      getAllRecentSearchLatestInteractor);
    Get.put(searchController);

    Get.testMode = true;

    mailboxDashboardController = MailboxDashBoardController(
      moveToMailboxInteractor,
      deleteEmailPermanentlyInteractor,
      markAsMailboxReadInteractor,
      getEmailCacheOnWebInteractor,
      getIdentityCacheOnWebInteractor,
      markAsEmailReadInteractor,
      markAsStarEmailInteractor,
      markAsMultipleEmailReadInteractor,
      markAsStarMultipleEmailInteractor,
      moveMultipleEmailToMailboxInteractor,
      emptyTrashFolderInteractor,
      deleteMultipleEmailsPermanentlyInteractor,
      getEmailByIdInteractor,
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
      removeComposerCacheOnWebInteractor,
      getAllIdentitiesInteractor,
      markAllAsUnreadSelectionAllEmailsInteractor,
      moveAllSelectionAllEmailsInteractor,
    );
  });

  group('search/sort/filter feature:', () {
    setUp(() {
      getEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();

      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));

      Get.put(mailboxDashboardController);
      mailboxDashboardController.onReady();

      mailboxController = MailboxController(
        createNewMailboxInteractor,
        deleteMultipleMailboxInteractor,
        renameMailboxInteractor,
        moveMailboxInteractor,
        subscribeMailboxInteractor,
        subscribeMultipleMailboxInteractor,
        subaddressingInteractor,
        createDefaultMailboxInteractor,
        treeBuilder,
        verifyNameInteractor,
        getAllMailboxInteractor,
        refreshAllMailboxInteractor);
      mailboxController.onReady();

      threadController = ThreadController(
        getEmailsInMailboxInteractor,
        refreshChangesEmailsInMailboxInteractor,
        loadMoreEmailsInMailboxInteractor,
        searchEmailInteractor,
        searchMoreEmailInteractor,
        getEmailByIdInteractor);
      Get.put(threadController);

      advancedFilterController = AdvancedFilterController();

      mailboxDashboardController.sessionCurrent = testSession;
      mailboxDashboardController.filterMessageOption.value = FilterMessageOption.all;
      mailboxDashboardController.accountId.value = testAccountId;
    });

    test('WHEN user search email by keyword, '
    'THEN user filter search result, '
    'THEN user tap on mail box, '
    'SHOULD reset all search and filter options, '
    'THEN query get all email with default options',
    () async {
      // arrange
      when(context.owner).thenReturn(BuildOwner(focusManager: FocusManager()));
      when(context.mounted).thenReturn(true);
      
      // expect query in search controller update as expected
      mailboxDashboardController.searchEmailByQueryString(queryString);
      expect(searchController.searchEmailFilter.value.text, SearchQuery(queryString));
      
      // expect sort in search controller update as expected
      mailboxDashboardController.selectSortOrderQuickSearchFilter(
        EmailSortOrderType.oldest);
      expect(searchController.sortOrderFiltered, EmailSortOrderType.oldest);

      // expect filter in search controller update as expected
      mailboxDashboardController.selectHasAttachmentSearchFilter();
      expect(searchController.searchEmailFilter.value.hasAttachment, true);
      mailboxDashboardController.selectReceiveTimeQuickSearchFilter(context, EmailReceiveTimeType.last30Days);
      expect(searchController.searchEmailFilter.value.emailReceiveTimeType, EmailReceiveTimeType.last30Days);

      // expect mailbox dashboard controller calls GetEmailsInMailboxInteractor
      // when [selectedMailbox] is changed and triggered obx listener in thread controller
      mailboxController.openMailbox(context, PresentationMailbox(testMailboxId));
      await untilCalled(getEmailsInMailboxInteractor.execute(
        any, any,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        emailFilter: anyNamed('emailFilter'),
        getLatestChanges: anyNamed('getLatestChanges'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated')));
      expect(searchController.sortOrderFiltered, EmailSortOrderType.mostRecent);
      expect(searchController.searchEmailFilter.value, SearchEmailFilter.initial());
      verify(getEmailsInMailboxInteractor.execute(
        testSession, testAccountId,
        limit: ThreadConstants.defaultLimit,
        sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
        emailFilter: EmailFilter(
          filter: EmailFilterCondition(inMailbox: testMailboxId),
          filterOption: FilterMessageOption.all,
          mailboxId: testMailboxId),
        getLatestChanges: false,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault));
    });

    test('WHEN user use advanced search/sort/filter feature, '
      'THEN user tap on mail box, '
      'SHOULD reset all advanced search and filter options, '
      'THEN query get all email with default options',
    () async {
      final fromEmailAddress = EmailAddress('test from', 'test-from@gmail.com');
      final toEmailAddress = EmailAddress('test to', 'test-to@gmail.com');
      const emailSubject = 'test subject';
      const emailContainsWord = 'test word';
      const emailNotContainsWord = 'test not word';
      // arrange
      when(context.owner).thenReturn(BuildOwner(focusManager: FocusManager()));
      when(context.mounted).thenReturn(true);

      // expect query in advanced filter controller update as expected
      advancedFilterController.updateListEmailAddress(AdvancedSearchFilterField.from, [fromEmailAddress]);
      advancedFilterController.updateListEmailAddress(AdvancedSearchFilterField.to, [toEmailAddress]);
      advancedFilterController.subjectFilterInputController.text = emailSubject;
      advancedFilterController.hasKeyWordFilterInputController.text = emailContainsWord;
      advancedFilterController.notKeyWordFilterInputController.text = emailNotContainsWord;
      // mailbox: impossible? due to private field
      advancedFilterController.updateReceiveDateSearchFilter(context, EmailReceiveTimeType.last30Days);
      advancedFilterController.updateSortOrder(EmailSortOrderType.relevance);
      advancedFilterController.applyAdvancedSearchFilter();
      expect(searchController.searchEmailFilter.value, SearchEmailFilter(
        from: {fromEmailAddress.email!},
        to: {toEmailAddress.email!},
        subject: emailSubject,
        sortOrderType: EmailSortOrderType.relevance,
        text: SearchQuery(emailContainsWord),
        notKeyword: {emailNotContainsWord},
        emailReceiveTimeType: EmailReceiveTimeType.last30Days,
        position: 0));

      // expect mailbox dashboard controller calls GetEmailsInMailboxInteractor
      // when [selectedMailbox] is changed and triggered obx listener in thread controller
      mailboxController.openMailbox(context, PresentationMailbox(testMailboxId));
      await untilCalled(getEmailsInMailboxInteractor.execute(
        any, any,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        emailFilter: anyNamed('emailFilter'),
        getLatestChanges: anyNamed('getLatestChanges'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated')));
      expect(searchController.sortOrderFiltered, EmailSortOrderType.mostRecent);
      expect(searchController.searchEmailFilter.value, SearchEmailFilter.initial());
      verify(getEmailsInMailboxInteractor.execute(
        testSession, testAccountId,
        limit: ThreadConstants.defaultLimit,
        sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
        emailFilter: EmailFilter(
          filter: EmailFilterCondition(inMailbox: testMailboxId),
          filterOption: FilterMessageOption.all,
          mailboxId: testMailboxId),
        getLatestChanges: false,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault
      )).called(1);
    });

    test(
      'WHEN user search email by keyword\n'
      'THEN user select chip filter\n'
      'SHOULD search filter matched with user changed',
    () async {
    // arrange
    when(context.owner).thenReturn(BuildOwner(focusManager: FocusManager()));

    // act
    mailboxDashboardController.searchEmailByQueryString(queryString);
    mailboxDashboardController.selectHasAttachmentSearchFilter();
    mailboxDashboardController.selectReceiveTimeQuickSearchFilter(context, EmailReceiveTimeType.last30Days);

    await untilCalled(searchEmailInteractor.execute(
      any,
      any,
      limit: anyNamed('limit'),
      position: anyNamed('position'),
      sort: anyNamed('sort'),
      filter: anyNamed('filter'),
      properties: anyNamed('properties')));

    // assert
    expect(
      searchController.searchEmailFilter.value,
      SearchEmailFilter(
        text: SearchQuery(queryString),
        emailReceiveTimeType: EmailReceiveTimeType.last30Days,
        hasAttachment: true,
      )
    );
  });

    tearDown(Get.deleteAll);
  });

  group('spamMailboxId:test', () {
    test('should returns Junk mailbox ID if it exists', () {
      // Arrange
      final spamMailboxId = MailboxId(Id('spam-id'));
      final junkMailboxId = MailboxId(Id('junk-id'));
      final mapDefaultMailboxIdByRole = {
        PresentationMailbox.roleSpam: spamMailboxId,
        PresentationMailbox.roleJunk: junkMailboxId,
      };
      mailboxDashboardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole);
      // Act
      final spamId = mailboxDashboardController.spamMailboxId;

      // Assert
      expect(spamId, equals(junkMailboxId));
    });

    test('should returns junk mailbox ID if spam ID does not exist', () {
      // Arrange
      final junkMailboxId = MailboxId(Id('junk-id'));
      final mapDefaultMailboxIdByRole = {
        PresentationMailbox.roleJunk: junkMailboxId,
      };
      mailboxDashboardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole);
      // Act
      final spamId = mailboxDashboardController.spamMailboxId;

      // Assert
      expect(spamId, equals(junkMailboxId));
    });

    test('should returns null if neither spam nor junk mailbox ID exists', () {
      // Arrange
      final mapDefaultMailboxIdByRole = <Role, MailboxId>{};
      mailboxDashboardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole);
      // Act
      final spamId = mailboxDashboardController.spamMailboxId;

      // Assert
      expect(spamId, isNull);
    });
  });

  group('getSubaddress:test', () {
    setUp(() {
      getEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();

      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));

      Get.put(mailboxDashboardController);
      mailboxDashboardController.onReady();

      mailboxController = MailboxController(
          createNewMailboxInteractor,
          deleteMultipleMailboxInteractor,
          renameMailboxInteractor,
          moveMailboxInteractor,
          subscribeMailboxInteractor,
          subscribeMultipleMailboxInteractor,
          subaddressingInteractor,
          createDefaultMailboxInteractor,
          treeBuilder,
          verifyNameInteractor,
          getAllMailboxInteractor,
          refreshAllMailboxInteractor);
      mailboxController.onReady();

      threadController = ThreadController(
          getEmailsInMailboxInteractor,
          refreshChangesEmailsInMailboxInteractor,
          loadMoreEmailsInMailboxInteractor,
          searchEmailInteractor,
          searchMoreEmailInteractor,
          getEmailByIdInteractor);
      Get.put(threadController);

      advancedFilterController = AdvancedFilterController();

      mailboxDashboardController.sessionCurrent = testSession;
      mailboxDashboardController.filterMessageOption.value = FilterMessageOption.all;
      mailboxDashboardController.accountId.value = testAccountId;
    });

    test('should return subaddress with valid email and folder name', () {
      const String userEmail = 'user@example.com';
      const String folderName = 'folder';
      final result = mailboxController.getSubaddress(userEmail, folderName);

      expect(result, equals('user+folder@example.com'));
    });

    test('should throw an error if empty local part', () {
      const userEmail = '@example.com';
      const folderName = 'folder';

      expect(() => mailboxController.getSubaddress(userEmail, folderName), throwsA(isA<InvalidMailFormatException>()));
    });

    test('should throw an error if empty folder name', () {
      const userEmail = 'user@example.com';
      const folderName = '';

      expect(() => mailboxController.getSubaddress(userEmail, folderName), throwsA(isA<EmptyFolderNameException>()));
    });

    test('should throw an error if empty domain', () {
      const userEmail = 'user@';
      const folderName = 'folder';

      expect(() => mailboxController.getSubaddress(userEmail, folderName), throwsA(isA<InvalidMailFormatException>()));
    });

    test('should throw an error if absent `@`', () {
      const userEmail = 'invalid-email-format';
      const folderName = 'folder';

      expect(() => mailboxController.getSubaddress(userEmail, folderName), throwsA(isA<InvalidMailFormatException>()));
    });
  });
}
