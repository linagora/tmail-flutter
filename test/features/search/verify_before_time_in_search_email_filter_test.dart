import 'dart:math' as math;

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:rxdart/rxdart.dart';
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
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/store_session_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/get_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/download/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_spam_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
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
  MockSpec<ApplicationManager>(),
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
  MockSpec<EmailReceiveManager>(),
  MockSpec<DownloadController>(fallbackGenerators: fallbackGenerators),
  MockSpec<AppGridDashboardController>(),
  MockSpec<SpamReportController>(fallbackGenerators: fallbackGenerators),
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<RemoveEmailDraftsInteractor>(),
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
  MockSpec<RemoveComposerCacheOnWebInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
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

  // Declaration search controller
  late SearchController searchController;
  late MockQuickSearchEmailInteractor mockQuickSearchEmailInteractor;
  late MockSaveRecentSearchInteractor mockSaveRecentSearchInteractor;
  late MockGetAllRecentSearchLatestInteractor mockGetAllRecentSearchLatestInteractor;

  // Declaration mailbox dashboard controller
  final MockGetSessionInteractor getSessionInteractor = MockGetSessionInteractor();
  final MockGetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
  final MockUpdateAccountCacheInteractor updateAccountCacheInteractor = MockUpdateAccountCacheInteractor();
  final MockRemoveEmailDraftsInteractor removeEmailDraftsInteractor = MockRemoveEmailDraftsInteractor();
  final MockEmailReceiveManager emailReceiveManager = MockEmailReceiveManager();
  final MockDownloadController downloadController = MockDownloadController();
  final MockAppGridDashboardController appGridDashboardController = MockAppGridDashboardController();
  final MockSpamReportController spamReportController = MockSpamReportController();
  final MockNetworkConnectionController networkConnectionController = MockNetworkConnectionController();

  late MailboxDashBoardController mailboxDashboardController;
  late MockMoveToMailboxInteractor moveToMailboxInteractor;
  late MockDeleteEmailPermanentlyInteractor deleteEmailPermanentlyInteractor;
  late MockMarkAsMailboxReadInteractor markAsMailboxReadInteractor;
  late MockGetComposerCacheOnWebInteractor getEmailCacheOnWebInteractor;
  late MockGetIdentityCacheOnWebInteractor getIdentityCacheOnWebInteractor;
  late MockMarkAsEmailReadInteractor markAsEmailReadInteractor;
  late MockMarkAsStarEmailInteractor markAsStarEmailInteractor;
  late MockMarkAsMultipleEmailReadInteractor markAsMultipleEmailReadInteractor;
  late MockMarkAsStarMultipleEmailInteractor markAsStarMultipleEmailInteractor;
  late MockMoveMultipleEmailToMailboxInteractor moveMultipleEmailToMailboxInteractor;
  late MockEmptyTrashFolderInteractor emptyTrashFolderInteractor;
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
  late MockRemoveComposerCacheOnWebInteractor removeComposerCacheOnWebInteractor;
  late MockGetAllIdentitiesInteractor getAllIdentitiesInteractor;

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
    mockApplicationManager = MockApplicationManager();
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
    Get.put<ApplicationManager>(mockApplicationManager);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    // Mock thread controller
    mockGetEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
    mockRefreshChangesEmailsInMailboxInteractor = MockRefreshChangesEmailsInMailboxInteractor();
    mockLoadMoreEmailsInMailboxInteractor = MockLoadMoreEmailsInMailboxInteractor();
    mockSearchEmailInteractor = MockSearchEmailInteractor();
    mockSearchMoreEmailInteractor = MockSearchMoreEmailInteractor();
    mockGetEmailByIdInteractor = MockGetEmailByIdInteractor();

    // Mock search controller
    mockQuickSearchEmailInteractor = MockQuickSearchEmailInteractor();
    mockSaveRecentSearchInteractor = MockSaveRecentSearchInteractor();
    mockGetAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();

    // Mock dashboard controller
    moveToMailboxInteractor = MockMoveToMailboxInteractor();
    deleteEmailPermanentlyInteractor = MockDeleteEmailPermanentlyInteractor();
    markAsMailboxReadInteractor = MockMarkAsMailboxReadInteractor();
    getEmailCacheOnWebInteractor = MockGetComposerCacheOnWebInteractor();
    getIdentityCacheOnWebInteractor = MockGetIdentityCacheOnWebInteractor();
    markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
    markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
    markAsMultipleEmailReadInteractor = MockMarkAsMultipleEmailReadInteractor();
    markAsStarMultipleEmailInteractor = MockMarkAsStarMultipleEmailInteractor();
    moveMultipleEmailToMailboxInteractor = MockMoveMultipleEmailToMailboxInteractor();
    emptyTrashFolderInteractor = MockEmptyTrashFolderInteractor();
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
    removeComposerCacheOnWebInteractor = MockRemoveComposerCacheOnWebInteractor();
    getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();

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
    Get.put<NetworkConnectionController>(networkConnectionController);
    Get.put<GetSessionInteractor>(getSessionInteractor);
    Get.put<GetAuthenticatedAccountInteractor>(getAuthenticatedAccountInteractor);
    Get.put<UpdateAccountCacheInteractor>(updateAccountCacheInteractor);

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
      removeComposerCacheOnWebInteractor,
      getAllIdentitiesInteractor,
    );

    when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));

    Get.put<MailboxDashBoardController>(mailboxDashboardController);

    threadController = ThreadController(
      mockGetEmailsInMailboxInteractor,
      mockRefreshChangesEmailsInMailboxInteractor,
      mockLoadMoreEmailsInMailboxInteractor,
      mockSearchEmailInteractor,
      mockSearchMoreEmailInteractor,
      mockGetEmailByIdInteractor,
    );

    mailboxDashboardController.sessionCurrent = SessionFixtures.aliceSession;
    mailboxDashboardController.filterMessageOption.value = FilterMessageOption.all;
    mailboxDashboardController.accountId.value = AccountFixtures.aliceAccountId;

    mailboxDashboardController.onInit();
  });

  List<PresentationEmail> generateEmailList({
    required DateTime startDate,
    required DateTime endDate,
    required int count,
    EmailSortOrderType? sortOrderType,
  }) {
    const uuid = Uuid();
    final random = math.Random();

    DateTime randomDate(DateTime start, DateTime end) {
      final differenceInSeconds = end.difference(start).inSeconds;
      final randomSeconds = random.nextInt(differenceInSeconds + 1);
      return start.add(Duration(seconds: randomSeconds));
    }

    List<PresentationEmail> emails = List.generate(count, (index) {
      final date = randomDate(startDate, endDate);
      return PresentationEmail(
        id: EmailId(Id(uuid.v4())),
        subject: 'Subject $index',
        receivedAt: UTCDate(date),
      );
    });

    if (sortOrderType != null) {
      switch (sortOrderType) {
        case EmailSortOrderType.mostRecent:
          emails.sort((a, b) => b.receivedAt!.value.compareTo(a.receivedAt!.value));
          break;
        case EmailSortOrderType.subjectAscending:
          emails.sort((a, b) => a.subject!.compareTo(b.subject!));
          break;
        default:
          break;
      }
    }

    return emails;
  }

  group('SearchEmailFilter::test', () {
    test(
      'WHEN ThreadController searches for emails in the time range from `2025/01/10` to `2025/01/20`\n'
      'AND SortBy is `Most recent, the result returns 20 elements.`\n'
      'THEN perform LOAD MORE EMAILS, now the value of `before` in search filter AND `before` in JMAP request\n'
      'SHOULD be `receivedAt` of last email',
    () async {
      // Arrange
      final startDate = DateTime(2025, 1, 10);
      final endDate = DateTime(2025, 1, 20, 23, 59, 59);
      final emailList = generateEmailList(
        startDate: startDate,
        endDate: endDate,
        count: 20,
        sortOrderType: EmailSortOrderType.mostRecent,
      );
      log('verify_before_time_in_search_email_filter_test::LoadMore::EmailList = ${emailList.map((email) => email.receivedAt.toString()).toList()}');
      final searchEmailFilter = SearchEmailFilter(
        sortOrderType: EmailSortOrderType.mostRecent,
        startDate: UTCDate(startDate),
        endDate: UTCDate(endDate),
      );

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      // Act
      searchController.synchronizeSearchFilter(searchEmailFilter);

      threadController.searchEmail();

      await untilCalled(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      ));

      // Assert
      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: ThreadConstants.defaultLimit,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: false,
      )).called(1);

      expect(
        mailboxDashboardController.emailsInCurrentMailbox,
        isNotEmpty,
      );
      expect(threadController.canSearchMore, isTrue);
      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      // Act
      threadController.searchMoreEmails();

      await untilCalled(mockSearchMoreEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        lastEmailId: anyNamed('lastEmailId'),
      ));

      final filterInJMapRequest = searchController
        .searchEmailFilter
        .value
        .mappingToEmailFilterCondition();

      // Assert
      verify(mockSearchMoreEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: ThreadConstants.defaultLimit,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        position: searchController.searchEmailFilter.value.position,
        filter: filterInJMapRequest,
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        lastEmailId: emailList.last.id,
      )).called(1);

      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        equals(emailList.last.receivedAt),
      );

      expect(filterInJMapRequest, isA<EmailFilterCondition>());
      final emailFilter = filterInJMapRequest as EmailFilterCondition;
      expect(emailFilter.before, equals(emailList.last.receivedAt));
    });

    test(
      'WHEN ThreadController searches for emails in the time range from `2025/01/10` to `2025/01/20`\n'
      'AND SortBy is `Subject: A-Z`, the result returns 20 elements.\n'
      'THEN perform LOAD MORE EMAILS, now the value of `before` in search filter is null AND `before` in JMAP request\n'
      'SHOULD be `endDate`',
    () async {
      // Arrange
      final startDate = DateTime(2025, 1, 10);
      final endDate = DateTime(2025, 1, 20, 23, 59, 59);
      final emailList = generateEmailList(
        startDate: startDate,
        endDate: endDate,
        count: 20,
        sortOrderType: EmailSortOrderType.subjectAscending
      );
      log('verify_before_time_in_search_email_filter_test::LoadMore::EmailList = ${emailList.map((email) => email.subject.toString()).toList()}');
      final searchEmailFilter = SearchEmailFilter(
        position: 0,
        sortOrderType: EmailSortOrderType.subjectAscending,
        startDate: UTCDate(startDate),
        endDate: UTCDate(endDate),
      );

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      // Act
      searchController.synchronizeSearchFilter(searchEmailFilter);

      threadController.searchEmail();

      await untilCalled(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      ));

      // Assert
      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: ThreadConstants.defaultLimit,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: false,
      )).called(1);

      expect(
        mailboxDashboardController.emailsInCurrentMailbox,
        isNotEmpty,
      );
      expect(threadController.canSearchMore, isTrue);
      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.position,
        equals(0),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      // Act
      threadController.searchMoreEmails();

      await untilCalled(mockSearchMoreEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        lastEmailId: anyNamed('lastEmailId'),
      ));

      final filterInJMapRequest = searchController
        .searchEmailFilter
        .value
        .mappingToEmailFilterCondition();

      // Assert
      verify(mockSearchMoreEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: ThreadConstants.defaultLimit,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        position: searchController.searchEmailFilter.value.position,
        filter: filterInJMapRequest,
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        lastEmailId: emailList.last.id,
      )).called(1);

      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.position,
        equals(20),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      expect(filterInJMapRequest, isA<EmailFilterCondition>());
      final emailFilter = filterInJMapRequest as EmailFilterCondition;
      expect(emailFilter.before, equals(UTCDate(endDate)));
    });

    test(
      'WHEN ThreadController searches for emails in the time range from `2025/01/10` to `2025/01/20`\n'
      'AND SortBy is `Most recent`, the result returns 20 elements\n'
      'THEN perform REFRESH EMAIL CHANGE, now the value of `before` in search filter is null AND `before` in JMAP request\n'
      'SHOULD be `endDate`',
    () async {
      // Arrange
      final startDate = DateTime(2025, 1, 10);
      final endDate = DateTime(2025, 1, 20, 23, 59, 59);
      final emailList = generateEmailList(
        startDate: startDate,
        endDate: endDate,
        count: 20,
        sortOrderType: EmailSortOrderType.mostRecent,
      );
      log('verify_before_time_in_search_email_filter_test::RefreshEmailChange::EmailList = ${emailList.map((email) => email.receivedAt.toString()).toList()}');
      final searchEmailFilter = SearchEmailFilter(
        sortOrderType: EmailSortOrderType.mostRecent,
        startDate: UTCDate(startDate),
        endDate: UTCDate(endDate),
      );

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      // Act
      searchController.synchronizeSearchFilter(searchEmailFilter);

      threadController.searchEmail();

      await untilCalled(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      ));

      // Assert
      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: ThreadConstants.defaultLimit,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: false,
      )).called(1);

      expect(
        mailboxDashboardController.emailsInCurrentMailbox,
        isNotEmpty,
      );
      expect(threadController.canSearchMore, isTrue);
      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      // Act
      mailboxDashboardController.setCurrentEmailState(State('current-state'));

      when(mockRefreshChangesEmailsInMailboxInteractor.execute(
        any,
        any,
        any,
        sort: anyNamed('sort'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
        emailFilter: anyNamed('emailFilter'),
      )).thenAnswer((_) => Stream.value(Right(RefreshChangesAllEmailSuccess(emailList: emailList))));

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      await threadController.refreshChangeSearchEmail();

      final filterInJMapRequest = searchController
        .searchEmailFilter
        .value
        .mappingToEmailFilterCondition();

      // Assert
      verify(mockRefreshChangesEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        mailboxDashboardController.currentEmailState!,
        sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
        propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        emailFilter: EmailFilter(
          filter: threadController.getFilterCondition(mailboxIdSelected: threadController.selectedMailboxId),
          filterOption: mailboxDashboardController.filterMessageOption.value,
          mailboxId: threadController.selectedMailboxId,
        ),
      )).called(1);

      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: threadController.limitEmailFetched,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: true,
      )).called(1);

      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      expect(filterInJMapRequest, isA<EmailFilterCondition>());
      final emailFilter = filterInJMapRequest as EmailFilterCondition;
      expect(emailFilter.before, equals(UTCDate(endDate)));
    });

    test(
      'WHEN ThreadController searches for emails in the time range from `2025/01/10` to `2025/01/20`\n'
      'AND SortBy is `Subject: A-Z`, the result returns 20 elements.\n'
      'THEN perform REFRESH EMAIL CHANGE, now the value of `before` in search filter is null AND `before` in JMAP request\n'
      'SHOULD be `endDate`',
    () async {
      // Arrange
      final startDate = DateTime(2025, 1, 10);
      final endDate = DateTime(2025, 1, 20, 23, 59, 59);
      final emailList = generateEmailList(
        startDate: startDate,
        endDate: endDate,
        count: 20,
        sortOrderType: EmailSortOrderType.subjectAscending,
      );
      log('verify_before_time_in_search_email_filter_test::RefreshEmailChange::EmailList = ${emailList.map((email) => email.subject.toString()).toList()}');
      final searchEmailFilter = SearchEmailFilter(
        position: 0,
        sortOrderType: EmailSortOrderType.subjectAscending,
        startDate: UTCDate(startDate),
        endDate: UTCDate(endDate),
      );

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      // Act
      searchController.synchronizeSearchFilter(searchEmailFilter);

      threadController.searchEmail();

      await untilCalled(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      ));

      // Assert
      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: ThreadConstants.defaultLimit,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: false
      )).called(1);

      expect(
        mailboxDashboardController.emailsInCurrentMailbox,
        isNotEmpty,
      );
      expect(threadController.canSearchMore, isTrue);
      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.position,
        equals(0),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      // Act
      mailboxDashboardController.setCurrentEmailState(State('current-state'));

      when(mockRefreshChangesEmailsInMailboxInteractor.execute(
        any,
        any,
        any,
        sort: anyNamed('sort'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
        emailFilter: anyNamed('emailFilter'),
      )).thenAnswer((_) => Stream.value(Right(RefreshChangesAllEmailSuccess(emailList: emailList))));

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      await threadController.refreshChangeSearchEmail();

      final filterInJMapRequest = searchController
        .searchEmailFilter
        .value
        .mappingToEmailFilterCondition();

      // Assert
      verify(mockRefreshChangesEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        mailboxDashboardController.currentEmailState!,
        sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
        propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        emailFilter: EmailFilter(
          filter: threadController.getFilterCondition(mailboxIdSelected: threadController.selectedMailboxId),
          filterOption: mailboxDashboardController.filterMessageOption.value,
          mailboxId: threadController.selectedMailboxId,
        ),
      )).called(1);

      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: threadController.limitEmailFetched,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: true,
      )).called(1);

      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.position,
        equals(0),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        isNull,
      );

      expect(filterInJMapRequest, isA<EmailFilterCondition>());
      final emailFilter = filterInJMapRequest as EmailFilterCondition;
      expect(emailFilter.before, equals(UTCDate(endDate)));
    });

    test(
      'WHEN ThreadController searches & load more for emails in the time range from `2025/01/10` to `2025/01/20`\n'
      'AND SortBy is `Subject: A-Z`, the result returns 40 elements.\n'
      'THEN perform REFRESH EMAIL CHANGE, now the value of `before` in search filter is `loadMoreDate` AND `before` in JMAP request\n'
      'SHOULD be `endDate`',
    () async {
      // Arrange
      final startDate = DateTime(2025, 1, 10);
      final endDate = DateTime(2025, 1, 20, 23, 59, 59);
      final loadMoreDate = DateTime(2025, 1, 15);
      final emailList = generateEmailList(
        startDate: startDate,
        endDate: endDate,
        count: 40,
        sortOrderType: EmailSortOrderType.subjectAscending,
      );
      log('verify_before_time_in_search_email_filter_test::RefreshEmailChange::EmailList = ${emailList.map((email) => email.subject.toString()).toList()}');
      final searchEmailFilter = SearchEmailFilter(
        position: 20,
        sortOrderType: EmailSortOrderType.subjectAscending,
        startDate: UTCDate(startDate),
        endDate: UTCDate(endDate),
        before: UTCDate(loadMoreDate),
      );

      // Act
      mailboxDashboardController.updateEmailList(emailList);
      searchController.synchronizeSearchFilter(searchEmailFilter);

      mailboxDashboardController.setCurrentEmailState(State('current-state'));

      when(mockRefreshChangesEmailsInMailboxInteractor.execute(
        any,
        any,
        any,
        sort: anyNamed('sort'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
        emailFilter: anyNamed('emailFilter'),
      )).thenAnswer((_) => Stream.value(Right(RefreshChangesAllEmailSuccess(emailList: emailList))));

      when(mockSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        position: anyNamed('position'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
        needRefreshSearchState: anyNamed('needRefreshSearchState'),
      )).thenAnswer((_) => Stream.value(Right(SearchEmailSuccess(emailList))));

      await threadController.refreshChangeSearchEmail();

      final filterInJMapRequest = searchController
        .searchEmailFilter
        .value
        .mappingToEmailFilterCondition();

      // Assert
      verify(mockRefreshChangesEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        mailboxDashboardController.currentEmailState!,
        sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
        propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        emailFilter: EmailFilter(
          filter: threadController.getFilterCondition(mailboxIdSelected: threadController.selectedMailboxId),
          filterOption: mailboxDashboardController.filterMessageOption.value,
          mailboxId: threadController.selectedMailboxId,
        ),
      )).called(1);

      verify(mockSearchEmailInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: threadController.limitEmailFetched,
        position: searchController.searchEmailFilter.value.position,
        sort: searchController.searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
        needRefreshSearchState: true,
      )).called(1);

      expect(
        searchController.searchEmailFilter.value.startDate,
        equals(UTCDate(startDate)),
      );
      expect(
        searchController.searchEmailFilter.value.endDate,
        equals(UTCDate(endDate)),
      );
      expect(
        searchController.searchEmailFilter.value.position,
        equals(0),
      );
      expect(
        searchController.searchEmailFilter.value.before,
        UTCDate(loadMoreDate),
      );

      expect(filterInJMapRequest, isA<EmailFilterCondition>());
      final emailFilter = filterInJMapRequest as EmailFilterCondition;
      expect(emailFilter.before, equals(UTCDate(loadMoreDate)));
    });
  });
}