
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/widgets.dart' hide State;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
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
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_by_id_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
    if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'mailbox_dashboard_controller_test.mocks.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';

// Mocks, controllers and setUp shared by the mailbox dashboard controller test files.
// mock mailbox dashboard controller direct dependencies
final moveToMailboxInteractor = MockMoveToMailboxInteractor();
final deleteEmailPermanentlyInteractor =
    MockDeleteEmailPermanentlyInteractor();
final markAsMailboxReadInteractor = MockMarkAsMailboxReadInteractor();
final getAllComposerCacheInteractor = MockGetAllComposerCacheInteractor();
final getIdentityCacheOnWebInteractor = MockGetIdentityCacheOnWebInteractor();
final markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
final markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
final markAsMultipleEmailReadInteractor =
    MockMarkAsMultipleEmailReadInteractor();
final markAsStarMultipleEmailInteractor =
    MockMarkAsStarMultipleEmailInteractor();
final moveMultipleEmailToMailboxInteractor =
    MockMoveMultipleEmailToMailboxInteractor();
final deleteMultipleEmailsPermanentlyInteractor =
    MockDeleteMultipleEmailsPermanentlyInteractor();
final getEmailByIdInteractor = MockGetEmailByIdInteractor();
final cleanAndGetEmailsInMailboxInteractor = MockCleanAndGetEmailsInMailboxInteractor();
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
final labelController = MockLabelController();
final networkConnectionController = MockNetworkConnectionController();

// mock search controller direct dependencies
final quickSearchEmailInteractor = MockQuickSearchEmailInteractor();
final saveRecentSearchInteractor = MockSaveRecentSearchInteractor();
final getAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();
final storeEmailSortOrderInteractor = MockStoreEmailSortOrderInteractor();
final getStoredEmailSortOrderInteractor = MockGetStoredEmailSortOrderInteractor();
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
final imagePaths = ImagePaths();
final responsiveUtils = MockResponsiveUtils();
final uuid = MockUuid();
final downloadAttachmentForWebInteractor = MockDownloadAttachmentForWebInteractor();
final parseEmailByBlobIdInteractor = MockParseEmailByBlobIdInteractor();
final mockToastManager = MockToastManager();
final mockTwakeAppManager = MockTwakeAppManager();

// mock reloadable controller Get dependencies
final getSessionInteractor = MockGetSessionInteractor();
final getAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
final updateAccountCacheInteractor = MockUpdateAccountCacheInteractor();
final getOidcUserInfoInteractor = MockGetOidcUserInfoInteractor();

// mock mailbox controller direct dependencies
final createNewMailboxInteractor = MockCreateNewMailboxInteractor();
final deleteMultipleMailboxInteractor = MockDeleteMultipleMailboxInteractor();
final renameMailboxInteractor = MockRenameMailboxInteractor();
final moveMailboxInteractor = MockMoveMailboxInteractor();
final subscribeMailboxInteractor = MockSubscribeMailboxInteractor();
final subscribeMultipleMailboxInteractor = MockSubscribeMultipleMailboxInteractor();
final subaddressingInteractor = MockSubaddressingInteractor();
final createDefaultMailboxInteractor = MockCreateDefaultMailboxInteractor();
final moveFolderContentInteractor = MockMoveFolderContentInteractor();
final treeBuilder = MockTreeBuilder();
final verifyNameInteractor = MockVerifyNameInteractor();
final getAllMailboxInteractor = MockGetAllMailboxInteractor();
final refreshAllMailboxInteractor = MockRefreshAllMailboxInteractor();
final removeAllComposerCacheInteractor = MockRemoveAllComposerCacheInteractor();
final removeComposerCacheByIdInteractor = MockRemoveComposerCacheByIdInteractor();
final getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
final clearMailboxInteractor = MockClearMailboxInteractor();
final getAuthenticationInfoInteractor = MockGetAuthenticationInfoInteractor();
final getStoredOidcConfigurationInteractor = MockGetStoredOidcConfigurationInteractor();
final getTokenOIDCInteractor = MockGetTokenOIDCInteractor();

final composerManager = MockComposerManager();
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

Future<void> pumpLocalizedApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const GetMaterialApp(
      locale: LocalizationService.defaultLocale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SizedBox(),
    ),
  );
  await tester.pump();
}

/// onInit schedules onReady for the next frame, so a test that calls it never calls onReady too.
MailboxController newMailboxController({TreeBuilder? mailboxTreeBuilder}) => MailboxController(
      createNewMailboxInteractor,
      deleteMultipleMailboxInteractor,
      renameMailboxInteractor,
      moveMailboxInteractor,
      subscribeMailboxInteractor,
      subscribeMultipleMailboxInteractor,
      subaddressingInteractor,
      createDefaultMailboxInteractor,
      moveFolderContentInteractor,
      mailboxTreeBuilder ?? treeBuilder,
      verifyNameInteractor,
      getAllMailboxInteractor,
      refreshAllMailboxInteractor,
    );

void setUpMailboxDashboardControllerTest() {
  setUp(() => ActiveAccountSourceFixtures.putShowing(null));

  setUp(() {
    _putDashboardDependencies();
    _putSessionAndAuthenticationDependencies();
    _putSearchController();
    Get.testMode = true;
    mailboxDashboardController = _newMailboxDashboardController();
  });

  // setUp builds a new dashboard for each test, so one a test put must not stay registered.
  tearDown(() => Get.delete<MailboxDashBoardController>(force: true));
}

void _putDashboardDependencies() {
  Get.put<RemoveEmailDraftsInteractor>(removeEmailDraftsInteractor);
  Get.put<EmailReceiveManager>(emailReceiveManager);
  Get.put<DownloadController>(downloadController);
  Get.put<AppGridDashboardController>(appGridDashboardController);
  Get.put<SpamReportController>(spamReportController);
  Get.put<LabelController>(labelController);
  // MailboxController listens to the label list once it is ready
  when(labelController.labels).thenReturn(RxList());
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
  Get.put<ToastManager>(mockToastManager);
  Get.put<TwakeAppManager>(mockTwakeAppManager);
}

void _putSessionAndAuthenticationDependencies() {
  Get.put<GetSessionInteractor>(getSessionInteractor);
  Get.put<GetAuthenticatedAccountInteractor>(getAuthenticatedAccountInteractor);
  Get.put<UpdateAccountCacheInteractor>(updateAccountCacheInteractor);
  Get.put<GetOidcUserInfoInteractor>(getOidcUserInfoInteractor);
  Get.put<GetAllIdentitiesInteractor>(getAllIdentitiesInteractor);
  Get.put<ClearMailboxInteractor>(clearMailboxInteractor);
  Get.put<RemoveAllComposerCacheInteractor>(removeAllComposerCacheInteractor);
  Get.put<RemoveComposerCacheByIdInteractor>(removeComposerCacheByIdInteractor);
  Get.put<ComposerManager>(composerManager);
  Get.put<GetAuthenticationInfoInteractor>(getAuthenticationInfoInteractor);
  Get.put<GetStoredOidcConfigurationInteractor>(getStoredOidcConfigurationInteractor);
  Get.put<GetTokenOIDCInteractor>(getTokenOIDCInteractor);
}

void _putSearchController() {
  searchController = SearchController(
    quickSearchEmailInteractor,
    saveRecentSearchInteractor,
    getAllRecentSearchLatestInteractor);
  Get.put(searchController);
}

MailboxDashBoardController _newMailboxDashboardController() {
  return MailboxDashBoardController(
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
    removeAllComposerCacheInteractor,
    removeComposerCacheByIdInteractor,
    getAllIdentitiesInteractor,
    clearMailboxInteractor,
    storeEmailSortOrderInteractor,
    getStoredEmailSortOrderInteractor,
  );
}
