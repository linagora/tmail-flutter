import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SearchController, State;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:model/extensions/mailbox_extension.dart';
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
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_default_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
 if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
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
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'mailbox_dashboard_view_widget_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
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
  MockSpec<AppGridDashboardController>(),
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
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<RemoveComposerCacheOnWebInteractor>(),
  MockSpec<ApplicationManager>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<GetQuotasInteractor>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<GetIdentityCacheOnWebInteractor>(),
])
void main() {
  final moveToMailboxInteractor = MockMoveToMailboxInteractor();
  final deleteEmailPermanentlyInteractor = MockDeleteEmailPermanentlyInteractor();
  final markAsMailboxReadInteractor = MockMarkAsMailboxReadInteractor();
  final getEmailCacheOnWebInteractor = MockGetComposerCacheOnWebInteractor();
  final getIdentityCacheOnWebInteractor = MockGetIdentityCacheOnWebInteractor();
  final markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
  final markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
  final markAsMultipleEmailReadInteractor = MockMarkAsMultipleEmailReadInteractor();
  final markAsStarMultipleEmailInteractor = MockMarkAsStarMultipleEmailInteractor();
  final moveMultipleEmailToMailboxInteractor = MockMoveMultipleEmailToMailboxInteractor();
  final emptyTrashFolderInteractor = MockEmptyTrashFolderInteractor();
  final deleteMultipleEmailsPermanentlyInteractor = MockDeleteMultipleEmailsPermanentlyInteractor();
  final getEmailByIdInteractor = MockGetEmailByIdInteractor();
  final sendEmailInteractor = MockSendEmailInteractor();
  final storeSendingEmailInteractor = MockStoreSendingEmailInteractor();
  final updateSendingEmailInteractor = MockUpdateSendingEmailInteractor();
  final getAllSendingEmailInteractor = MockGetAllSendingEmailInteractor();
  final storeSessionInteractor = MockStoreSessionInteractor();
  final emptySpamFolderInteractor = MockEmptySpamFolderInteractor();
  final deleteSendingEmailInteractor = MockDeleteSendingEmailInteractor();
  final unsubscribeEmailInteractor = MockUnsubscribeEmailInteractor();
  final restoreDeletedMessageInteractor = MockRestoredDeletedMessageInteractor();
  final getRestoredDeletedMessageInteractor = MockGetRestoredDeletedMessageInterator();

  final removeEmailDraftsInteractor = MockRemoveEmailDraftsInteractor();
  final emailReceiveManager = MockEmailReceiveManager();
  final downloadController = MockDownloadController();
  final appGridDashboardController = MockAppGridDashboardController();
  final spamReportController = MockSpamReportController();
  final networkConnectionController = MockNetworkConnectionController();

  final quickSearchEmailInteractor = MockQuickSearchEmailInteractor();
  final saveRecentSearchInteractor = MockSaveRecentSearchInteractor();
  final getAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();

  final cachingManager = MockCachingManager();
  final languageCacheManager = MockLanguageCacheManager();
  final authorizationInterceptors = MockAuthorizationInterceptors();
  final dynamicUrlInterceptors = MockDynamicUrlInterceptors();
  final deleteCredentialInteractor = MockDeleteCredentialInteractor();
  final logoutOidcInteractor = MockLogoutOidcInteractor();
  final deleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
  final appToast = MockAppToast();
  final toastManager = MockToastManager();
  final mockTwakeAppManager = MockTwakeAppManager();
  final imagePaths = ImagePaths();
  final responsiveUtils = MockResponsiveUtils();
  final uuid = MockUuid();
  final applicationManager = MockApplicationManager();

  final getSessionInteractor = MockGetSessionInteractor();
  final getAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
  final updateAccountCacheInteractor = MockUpdateAccountCacheInteractor();

  final createNewMailboxInteractor = MockCreateNewMailboxInteractor();
  final deleteMultipleMailboxInteractor = MockDeleteMultipleMailboxInteractor();
  final renameMailboxInteractor = MockRenameMailboxInteractor();
  final moveMailboxInteractor = MockMoveMailboxInteractor();
  final subscribeMailboxInteractor = MockSubscribeMailboxInteractor();
  final subscribeMultipleMailboxInteractor = MockSubscribeMultipleMailboxInteractor();
  final createDefaultMailboxInteractor = MockCreateDefaultMailboxInteractor();
  final treeBuilder = MockTreeBuilder();
  final verifyNameInteractor = MockVerifyNameInteractor();
  final getAllMailboxInteractor = MockGetAllMailboxInteractor();
  final refreshAllMailboxInteractor = MockRefreshAllMailboxInteractor();
  final removeComposerCacheOnWebInteractor = MockRemoveComposerCacheOnWebInteractor();
  final getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();

  final getEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
  final refreshChangesEmailsInMailboxInteractor = MockRefreshChangesEmailsInMailboxInteractor();
  final loadMoreEmailsInMailboxInteractor = MockLoadMoreEmailsInMailboxInteractor();
  final searchEmailInteractor = MockSearchEmailInteractor();
  final searchMoreEmailInteractor = MockSearchMoreEmailInteractor();

  final getQuotasInteractor = MockGetQuotasInteractor();

  late MailboxDashBoardController mailboxDashboardController;
  late SearchController searchController;
  late MailboxController mailboxController;
  late ThreadController threadController;
  late QuotasController quotasController;

  Widget makeTestableWidget({required Widget child}) {
    return GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      locale: LocalizationService.defaultLocale,
      home: Scaffold(body: child),
    );
  }

  group('MailboxDashboardView::WidgetTest::OnWeb', () {
    setUp(() {
      Get.testMode = true;

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
      Get.put<ToastManager>(toastManager);
      Get.put<TwakeAppManager>(mockTwakeAppManager);
      Get.put<ImagePaths>(imagePaths);
      Get.put<ResponsiveUtils>(responsiveUtils);
      Get.put<Uuid>(uuid);
      Get.put<ApplicationManager>(applicationManager);
      Get.put<GetSessionInteractor>(getSessionInteractor);
      Get.put<GetAuthenticatedAccountInteractor>(getAuthenticatedAccountInteractor);
      Get.put<UpdateAccountCacheInteractor>(updateAccountCacheInteractor);
      Get.put<GetAllIdentitiesInteractor>(getAllIdentitiesInteractor);
      Get.put<RemoveComposerCacheOnWebInteractor>(removeComposerCacheOnWebInteractor);

      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));

      searchController = SearchController(
        quickSearchEmailInteractor,
        saveRecentSearchInteractor,
        getAllRecentSearchLatestInteractor
      );
      Get.put(searchController);

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
      );
      Get.put(mailboxDashboardController);
      mailboxDashboardController.onReady();

      mailboxController = MailboxController(
        createNewMailboxInteractor,
        deleteMultipleMailboxInteractor,
        renameMailboxInteractor,
        moveMailboxInteractor,
        subscribeMailboxInteractor,
        subscribeMultipleMailboxInteractor,
        createDefaultMailboxInteractor,
        treeBuilder,
        verifyNameInteractor,
        getAllMailboxInteractor,
        refreshAllMailboxInteractor
      );
      mailboxController.onReady();

      threadController = ThreadController(
        getEmailsInMailboxInteractor,
        refreshChangesEmailsInMailboxInteractor,
        loadMoreEmailsInMailboxInteractor,
        searchEmailInteractor,
        searchMoreEmailInteractor,
        getEmailByIdInteractor
      );
      Get.put(threadController);

      quotasController = QuotasController(getQuotasInteractor);
      Get.put(quotasController);

      mailboxDashboardController.sessionCurrent = SessionFixtures.aliceSession;
      mailboxDashboardController.filterMessageOption.value = FilterMessageOption.all;
      mailboxDashboardController.accountId.value = AccountFixtures.aliceAccountId;
    });

    group('ThreadView::test', () {
      testWidgets(
        'WHEN switch from old mailbox to new mailbox\n'
        'AND old mailbox and new mailbox both have emails\n'
        'ThreadView SHOULD not load emails from the old mailbox',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final dpi = tester.view.devicePixelRatio;
        tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

        when(mailboxDashboardController.spamReportController.spamReportState).thenReturn(Rx(SpamReportState.disabled));
        when(mailboxDashboardController.spamReportController.presentationSpamMailbox).thenReturn(Rxn(null));
        when(mailboxDashboardController.downloadController.listDownloadTaskState).thenReturn(RxList([]));

        final widget = makeTestableWidget(child: MailboxDashBoardView());
        await tester.pumpWidget(widget);

        // Open mailbox Inbox
        final listEmailsOfInbox = <PresentationEmail>[
          EmailFixtures.email1.toPresentationEmail(),
          EmailFixtures.email2.toPresentationEmail(),
          EmailFixtures.email3.toPresentationEmail(),
        ];
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.inboxMailbox.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfInbox);

        await tester.pump();

        final threadViewFinder = find.byType(ThreadView);
        expect(threadViewFinder, findsOneWidget);

        final emptyEmailWidgetFinder = find.byKey(const Key('empty_thread_view'));
        expect(emptyEmailWidgetFinder, findsNothing);

        final listViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(listViewEmailWidgetFinder, findsOneWidget);

        final listViewEmailWidget = tester.widget<ListView>(listViewEmailWidgetFinder);
        expect(listViewEmailWidget.semanticChildCount, equals(listEmailsOfInbox.length + 2));

        final emailTile1Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email1.toPresentationEmail().id?.asString}'),);
        expect(emailTile1Finder, findsOneWidget);

        final emailTile2Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email2.toPresentationEmail().id?.asString}'),);
        expect(emailTile2Finder, findsOneWidget);

        final emailTile3Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email3.toPresentationEmail().id?.asString}'),);
        expect(emailTile3Finder, findsOneWidget);

        // Switch to mailbox Folder 1
        final listEmailsOfFolder1 = <PresentationEmail>[
          EmailFixtures.email4.toPresentationEmail(),
          EmailFixtures.email5.toPresentationEmail(),
        ];
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.folder1.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfFolder1);

        await tester.pump();

        final folder1EmptyEmailWidgetFinder = find.byKey(const Key('empty_thread_view'));
        expect(folder1EmptyEmailWidgetFinder, findsNothing);

        final folder1ListViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(folder1ListViewEmailWidgetFinder, findsOneWidget);

        final folder1ListViewEmailWidget = tester.widget<ListView>(folder1ListViewEmailWidgetFinder);
        expect(folder1ListViewEmailWidget.semanticChildCount, equals(listEmailsOfFolder1.length + 2));

        final emailTile4Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email4.toPresentationEmail().id?.asString}'),);
        expect(emailTile4Finder, findsOneWidget);

        final emailTile5Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email5.toPresentationEmail().id?.asString}'),);
        expect(emailTile5Finder, findsOneWidget);

        expect(emailTile1Finder, findsNothing);
        expect(emailTile2Finder, findsNothing);
        expect(emailTile3Finder, findsNothing);

        debugDefaultTargetPlatformOverride = null;
        tester.view.reset();
      });

      testWidgets(
        'WHEN switch new mailbox\n'
        'AND new mailbox has email\n'
        'ThreadView SHOULD not display empty view',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final dpi = tester.view.devicePixelRatio;
        tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

        when(mailboxDashboardController.spamReportController.spamReportState).thenReturn(Rx(SpamReportState.disabled));
        when(mailboxDashboardController.spamReportController.presentationSpamMailbox).thenReturn(Rxn(null));
        when(mailboxDashboardController.downloadController.listDownloadTaskState).thenReturn(RxList([]));

        final widget = makeTestableWidget(child: MailboxDashBoardView());
        await tester.pumpWidget(widget);

        // Open mailbox Inbox
        final listEmailsOfInbox = <PresentationEmail>[];
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.inboxMailbox.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfInbox);

        threadController.consumeState(
          Stream.value(Right(GetAllEmailSuccess(
            emailList: listEmailsOfInbox,
            currentMailboxId: MailboxFixtures.inboxMailbox.id
          )))
        );

        await tester.pump();

        final emptyEmailWidgetFinder = find.byKey(const Key('empty_thread_view'));
        expect(emptyEmailWidgetFinder, findsOneWidget);

        final listViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(listViewEmailWidgetFinder, findsNothing);

        // Switch to mailbox Folder 1
        final listEmailsOfFolder1 = [
          EmailFixtures.email1.toPresentationEmail(),
          EmailFixtures.email2.toPresentationEmail(),
        ];
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.folder1.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfFolder1);

        await tester.pump();

        final folder1EmptyEmailWidgetFinder = find.byKey(const Key('empty_thread_view'));
        expect(folder1EmptyEmailWidgetFinder, findsNothing);

        final folder1ListViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(folder1ListViewEmailWidgetFinder, findsOneWidget);

        final folder1ListViewEmailWidget = tester.widget<ListView>(folder1ListViewEmailWidgetFinder);
        expect(folder1ListViewEmailWidget.semanticChildCount, equals(listEmailsOfFolder1.length + 2));

        final emailTile1Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email1.toPresentationEmail().id?.asString}'),);
        expect(emailTile1Finder, findsOneWidget);

        final emailTile2Finder = find.byKey(Key('email_tile_builder_${EmailFixtures.email2.toPresentationEmail().id?.asString}'),);
        expect(emailTile2Finder, findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
        tester.view.reset();
      });

      testWidgets(
        'WHEN switch from old mailbox to new mailbox\n'
        'AND old mailbox has email, new mailbox has no email\n'
        'ThreadView SHOULD display empty view',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final dpi = tester.view.devicePixelRatio;
        tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

        when(mailboxDashboardController.spamReportController.spamReportState).thenReturn(Rx(SpamReportState.disabled));
        when(mailboxDashboardController.spamReportController.presentationSpamMailbox).thenReturn(Rxn(null));
        when(mailboxDashboardController.downloadController.listDownloadTaskState).thenReturn(RxList([]));

        final widget = makeTestableWidget(child: MailboxDashBoardView());
        await tester.pumpWidget(widget);

        // Open mailbox Inbox
        final listEmailsOfInbox = <PresentationEmail>[
          EmailFixtures.email1.toPresentationEmail(),
          EmailFixtures.email2.toPresentationEmail(),
        ];
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.inboxMailbox.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfInbox);

        threadController.consumeState(
          Stream.value(Right(GetAllEmailSuccess(
            emailList: listEmailsOfInbox,
            currentMailboxId: MailboxFixtures.inboxMailbox.id
          )))
        );

        await tester.pump();

        final emptyEmailWidgetFinder = find.byKey(const Key('empty_thread_view'));
        expect(emptyEmailWidgetFinder, findsNothing);

        final listViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        final listViewEmailWidget = tester.widget<ListView>(listViewEmailWidgetFinder);
        expect(listViewEmailWidget.semanticChildCount, equals(listEmailsOfInbox.length + 2));

        // Switch to mailbox Folder 1
        final listEmailsOfFolder1 = <PresentationEmail>[];
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.folder1.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfFolder1);

        threadController.consumeState(
          Stream.value(Right(GetAllEmailSuccess(
            emailList: listEmailsOfFolder1,
            currentMailboxId: MailboxFixtures.folder1.id
          )))
        );

        await tester.pump();

        final folder1EmptyEmailWidgetFinder = find.byKey(const Key('empty_thread_view'));
        expect(folder1EmptyEmailWidgetFinder, findsOneWidget);

        final folder1ListViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(folder1ListViewEmailWidgetFinder, findsNothing);

        debugDefaultTargetPlatformOverride = null;
        tester.view.reset();
      });

      testWidgets(
        'LoadMoreButton SHOULD be displayed\n'
        'WHEN the load more action returns a non-empty list',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final dpi = tester.view.devicePixelRatio;
        tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

        when(mailboxDashboardController.spamReportController.spamReportState).thenReturn(Rx(SpamReportState.disabled));
        when(mailboxDashboardController.spamReportController.presentationSpamMailbox).thenReturn(Rxn(null));
        when(mailboxDashboardController.downloadController.listDownloadTaskState).thenReturn(RxList([]));

        final widget = makeTestableWidget(child: MailboxDashBoardView());
        await tester.pumpWidget(widget);

        // Open mailbox Inbox
        final listEmailsOfInbox = List.generate(
          3,
          (index) => PresentationEmail(
            id: EmailId(Id('id_$index')),
            mailboxIds: {
              MailboxFixtures.inboxMailbox.id!: true
            }
          ));
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.inboxMailbox.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfInbox);

        // Perform load more action
        final emailList = <PresentationEmail>[
          PresentationEmail(
            id: EmailId(Id('id_4')),
            mailboxIds: {
              MailboxFixtures.inboxMailbox.id!: true
            }
          ),
          PresentationEmail(
            id: EmailId(Id('id_5')),
            mailboxIds: {
              MailboxFixtures.inboxMailbox.id!: true
            }
          ),
        ];
        threadController.consumeState(Stream.value(Right(LoadMoreEmailsSuccess(emailList))));

        await tester.pump();

        final listViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(listViewEmailWidgetFinder, findsOneWidget);

        final listViewEmailWidget = tester.widget<ListView>(listViewEmailWidgetFinder);
        expect(listViewEmailWidget.semanticChildCount, equals(7));

        expect(find.text('Load more'), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
        tester.view.reset();
      });

      testWidgets(
        'LoadMoreButton SHOULD not be displayed\n'
        'WHEN the load more action returns a empty list',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final dpi = tester.view.devicePixelRatio;
        tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

        when(mailboxDashboardController.spamReportController.spamReportState).thenReturn(Rx(SpamReportState.disabled));
        when(mailboxDashboardController.spamReportController.presentationSpamMailbox).thenReturn(Rxn(null));
        when(mailboxDashboardController.downloadController.listDownloadTaskState).thenReturn(RxList([]));

        final widget = makeTestableWidget(child: MailboxDashBoardView());
        await tester.pumpWidget(widget);

        // Open mailbox Inbox
        final listEmailsOfInbox = List.generate(
          3,
          (index) => PresentationEmail(
            id: EmailId(Id('id_$index')),
            mailboxIds: {
              MailboxFixtures.inboxMailbox.id!: true
            }
          ));
        mailboxDashboardController.setSelectedMailbox(MailboxFixtures.inboxMailbox.toPresentationMailbox());
        mailboxDashboardController.updateEmailList(listEmailsOfInbox);

        // Perform load more action
        final emailList = <PresentationEmail>[];
        threadController.consumeState(Stream.value(Right(LoadMoreEmailsSuccess(emailList))));

        await tester.pump();

        final listViewEmailWidgetFinder = find.byKey(const PageStorageKey('list_presentation_email_in_threads'));
        expect(listViewEmailWidgetFinder, findsOneWidget);

        final listViewEmailWidget = tester.widget<ListView>(listViewEmailWidgetFinder);
        expect(listViewEmailWidget.semanticChildCount, equals(5));

        expect(find.text('Load more'), findsNothing);

        debugDefaultTargetPlatformOverride = null;
        tester.view.reset();
      });
    });

    tearDown(Get.deleteAll);
  });
}
