import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/presentation/cleanup_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/print_file_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_hive_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_local_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_session_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/print_file_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_and_get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/get_html_content_from_upload_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_restored_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/remove_a_label_from_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/restore_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/store_session_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource/identity_creator_data_source.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource_impl/local_identity_creator_data_source_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/data/repository/identity_creator_repository_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/get_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/clear_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/app_grid_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/app_grid_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/hive_spam_report_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/local_app_grid_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/local_spam_report_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/search_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/session_storage_composer_datasoure_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_sort_order_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/app_grid_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/search_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/spam_report_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/app_grid_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_app_dashboard_configuration_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_app_grid_linagra_ecosystem_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_mailbox_cached_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_stored_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_text_formatting_menu_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_by_id_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_text_formatting_menu_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_last_time_dismissed_spam_reported_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/download/presentation/bindings/download_interactor_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_ai_scribe_config_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/bindings/setting_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_bindings.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_bindings.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/bindings/sending_queue_bindings.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/bindings/sending_queue_interactor_bindings.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource_impl/remote_server_settings_data_source_impl.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/data/repository/server_settings_repository_impl.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/local_thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/datasource_impl/thread_datasource_impl.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_spam_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_bindings.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_bindings.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class MailboxDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    CleanupBindings().dependencies();
    super.dependencies();
    SendingQueueBindings().dependencies();
    MailboxBindings().dependencies();
    ThreadBindings().dependencies();
    EmailBindings().dependencies();
    SearchEmailBindings().dependencies();
    QuotasBindings().dependencies();
    ThreadDetailBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.put(AppGridDashboardController(
      Get.find<GetAppDashboardConfigurationInteractor>(),
      Get.find<GetAppGridLinagraEcosystemInteractor>(),
    ));
    Get.put(DownloadController(
      Get.find<DownloadManager>(),
      Get.find<PrintUtils>(),
      Get.find<DownloadAttachmentForWebInteractor>(),
      Get.find<DownloadAllAttachmentsForWebInteractor>(),
      Get.find<ParseEmailByBlobIdInteractor>(),
      Get.find<PreviewEmailFromEmlFileInteractor>(),
      Get.find<DownloadAndGetHtmlContentFromAttachmentInteractor>(),
      Get.find<GetHtmlContentFromUploadFileInteractor>(),
      Get.find<ExportAttachmentInteractor>(),
      Get.find<ExportAllAttachmentsInteractor>(),
    ));
    Get.put(SearchController(
      Get.find<QuickSearchEmailInteractor>(),
      Get.find<SaveRecentSearchInteractor>(),
      Get.find<GetAllRecentSearchLatestInteractor>(),
    ));

    Get.put(SpamReportController(
      Get.find<StoreSpamReportInteractor>(),
      Get.find<StoreSpamReportStateInteractor>(),
      Get.find<GetSpamReportStateInteractor>(),
      Get.find<GetSpamMailboxCachedInteractor>()));

    Get.put(LabelController());

    Get.lazyPut(() => ComposerManager());

    Get.put(MailboxDashBoardController(
      Get.find<MoveToMailboxInteractor>(),
      Get.find<DeleteEmailPermanentlyInteractor>(),
      Get.find<MarkAsMailboxReadInteractor>(),
      Get.find<GetComposerCacheOnWebInteractor>(),
      Get.find<GetIdentityCacheOnWebInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<MarkAsStarEmailInteractor>(),
      Get.find<MarkAsMultipleEmailReadInteractor>(),
      Get.find<MarkAsStarMultipleEmailInteractor>(),
      Get.find<MoveMultipleEmailToMailboxInteractor>(),
      Get.find<EmptyTrashFolderInteractor>(),
      Get.find<DeleteMultipleEmailsPermanentlyInteractor>(),
      Get.find<GetEmailByIdInteractor>(),
      Get.find<SendEmailInteractor>(),
      Get.find<StoreSendingEmailInteractor>(),
      Get.find<UpdateSendingEmailInteractor>(),
      Get.find<GetAllSendingEmailInteractor>(),
      Get.find<StoreSessionInteractor>(),
      Get.find<EmptySpamFolderInteractor>(),
      Get.find<DeleteSendingEmailInteractor>(),
      Get.find<UnsubscribeEmailInteractor>(),
      Get.find<RestoredDeletedMessageInteractor>(),
      Get.find<GetRestoredDeletedMessageInterator>(),
      Get.find<RemoveAllComposerCacheOnWebInteractor>(),
      Get.find<RemoveComposerCacheByIdOnWebInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<ClearMailboxInteractor>(),
      Get.find<StoreEmailSortOrderInteractor>(),
      Get.find<GetStoredEmailSortOrderInteractor>(),
    ));
    Get.put(AdvancedFilterController());
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<SearchDataSource>(() => Get.find<SearchDataSourceImpl>());
    Get.lazyPut<ThreadDataSource>(() => Get.find<ThreadDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<PrintFileDataSource>(() => Get.find<PrintFileDataSourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<SessionStorageComposerDatasource>(() => Get.find<SessionStorageComposerDatasourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<MailboxCacheDataSourceImpl>(() => Get.find<MailboxCacheDataSourceImpl>());
    Get.lazyPut<ServerSettingsDataSource>(
      () => Get.find<RemoteServerSettingsDataSourceImpl>());
    Get.lazyPut<IdentityCreatorDataSource>(() => Get.find<LocalIdentityCreatorDataSourceImpl>());
    Get.lazyPut<AppGridDatasource>(() => Get.find<AppGridDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => EmailDataSourceImpl(
      Get.find<EmailAPI>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => SearchDataSourceImpl(
      Get.find<RecentSearchCacheManager>(),
      Get.find<LocalSortOrderManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => ThreadDataSourceImpl(
      Get.find<ThreadAPI>(),
      Get.find<ThreadIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => LocalThreadDataSourceImpl(
      Get.find<EmailCacheManager>(),
      Get.find<CachingManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheManager>(),
      Get.find<IOSSharingManager>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => PrintFileDataSourceImpl(
      Get.find<PrintUtils>(),
      Get.find<ImagePaths>(),
      Get.find<FileUtils>(),
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => MailboxDataSourceImpl(
      Get.find<MailboxAPI>(),
      Get.find<MailboxIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => SessionStorageComposerDatasourceImpl(
      Get.find<HtmlTransform>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => LocalSpamReportDataSourceImpl(
      Get.find<PreferencesSettingManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
    Get.lazyPut(() => HiveSpamReportDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailHiveCacheDataSourceImpl(
      Get.find<NewEmailCacheManager>(),
      Get.find<OpenedEmailCacheManager>(),
      Get.find<NewEmailCacheWorkerQueue>(),
      Get.find<OpenedEmailCacheWorkerQueue>(),
      Get.find<EmailCacheManager>(),
      Get.find<SendingEmailCacheManager>(),
      Get.find<FileUtils>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailLocalStorageDataSourceImpl(
      Get.find<LocalStorageManager>(),
      Get.find<PreviewEmlFileUtils>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailSessionStorageDatasourceImpl(
      Get.find<SessionStorageManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(),
      Get.find<RemoteExceptionThrower>()
    ));
    Get.lazyPut(() => LocalIdentityCreatorDataSourceImpl(
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => AppGridDatasourceImpl(
      Get.find<LinagoraEcosystemApi>(),
      Get.find<RemoteExceptionThrower>(),
    ));
    Get.lazyPut(() => LocalAppGridDatasourceImpl(
      Get.find<AppConfigLoader>(),
      Get.find<CacheExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => RemoveEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DeleteEmailPermanentlyInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveRecentSearchInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => GetAllRecentSearchLatestInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => StoreEmailSortOrderInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => GetStoredEmailSortOrderInteractor(Get.find<SearchRepository>()));
    Get.lazyPut(() => SearchEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => SearchMoreEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => RefreshChangesSearchEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => QuickSearchEmailInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => MarkAsMailboxReadInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => GetComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => RemoveComposerCacheByIdOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => RemoveAllComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => MarkAsEmailReadInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsStarEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsMultipleEmailReadInteractor(
        Get.find<EmailRepository>(),
    ));
    Get.lazyPut(() => MarkAsStarMultipleEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => AddALabelToAThreadInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => RemoveALabelFromAThreadInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MoveMultipleEmailToMailboxInteractor(
        Get.find<EmailRepository>(),
    ));
    Get.lazyPut(() => DeleteMultipleEmailsPermanentlyInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => EmptyTrashFolderInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => EmptySpamFolderInteractor(Get.find<ThreadRepository>()));
    Get.lazyPut(() => GetAppDashboardConfigurationInteractor(Get.find<AppGridRepository>()));
    Get.lazyPut(() => GetAppGridLinagraEcosystemInteractor(Get.find<AppGridRepository>()));
    Get.lazyPut(() => GetEmailByIdInteractor(
      Get.find<ThreadRepository>(),
      Get.find<EmailRepository>()));
    Get.lazyPut(() => StoreSpamReportInteractor(
      Get.find<SpamReportRepository>()));
    Get.lazyPut(() => StoreSpamReportStateInteractor(
      Get.find<SpamReportRepository>()));
    Get.lazyPut(() => GetSpamReportStateInteractor(
      Get.find<SpamReportRepository>()));
    Get.lazyPut(() => GetSpamMailboxCachedInteractor(Get.find<SpamReportRepository>()));
    Get.lazyPut(() => SendEmailInteractor(Get.find<EmailRepository>()));
    SendingQueueInteractorBindings().dependencies();
    Get.lazyPut(() => StoreSessionInteractor(Get.find<SessionRepository>()));
    Get.lazyPut(() => UnsubscribeEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => RestoredDeletedMessageInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetRestoredDeletedMessageInterator(
      Get.find<EmailRepository>(),
      Get.find<MailboxRepository>()
    ));
    Get.lazyPut(() => ClearMailboxInteractor(Get.find<MailboxRepository>()));

    IdentityInteractorsBindings().dependencies();
    Get.lazyPut(() => GetAllIdentitiesInteractor(
      Get.find<IdentityRepository>(),
      Get.find<IdentityUtils>()
    ));
    Get.lazyPut(() => GetIdentityCacheOnWebInteractor(
      Get.find<IdentityCreatorRepository>()
    ));
    PaywallBindings().dependencies();

    DownloadInteractorBindings().dependencies();

    SettingInteractorBindings().dependencies();
    Get.lazyPut(
      () => GetTextFormattingMenuStateInteractor(
        Get.find<ManageAccountRepository>(),
      ),
    );
    Get.lazyPut(
      () => SaveTextFormattingMenuStateInteractor(
        Get.find<ManageAccountRepository>(),
      ),
    );
    if (!PlatformInfo.isMobile) {
      Get.lazyPut(
        () => GetAIScribeConfigInteractor(Get.find<ManageAccountRepository>()),
      );
    }
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<SearchRepository>(() => Get.find<SearchRepositoryImpl>());
    Get.lazyPut<ThreadRepository>(() => Get.find<ThreadRepositoryImpl>());
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut<ComposerCacheRepository>(() => Get.find<ComposerCacheRepositoryImpl>());
    Get.lazyPut<SpamReportRepository>(() => Get.find<SpamReportRepositoryImpl>());
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut<ServerSettingsRepository>(() => Get.find<ServerSettingsRepositoryImpl>());
    Get.lazyPut<IdentityCreatorRepository>(() => Get.find<IdentityCreatorRepositoryImpl>());
    Get.lazyPut<AppGridRepository>(() => Get.find<AppGridRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => EmailRepositoryImpl(
      {
        DataSourceType.network: Get.find<EmailDataSource>(),
        DataSourceType.hiveCache: Get.find<EmailHiveCacheDataSourceImpl>(),
        DataSourceType.local: Get.find<EmailLocalStorageDataSourceImpl>(),
        DataSourceType.session: Get.find<EmailSessionStorageDatasourceImpl>(),
      },
      Get.find<HtmlDataSource>(),
      Get.find<StateDataSource>(),
      Get.find<PrintFileDataSource>(),
    ));
    Get.lazyPut(() => SearchRepositoryImpl(Get.find<SearchDataSource>()));
    Get.lazyPut(() => ThreadRepositoryImpl(
      {
        DataSourceType.network: Get.find<ThreadDataSource>(),
        DataSourceType.local: Get.find<LocalThreadDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
    Get.lazyPut(() => ComposerCacheRepositoryImpl(Get.find<SessionStorageComposerDatasource>()));
    Get.lazyPut(() => SpamReportRepositoryImpl(
      {
        DataSourceType.local: Get.find<LocalSpamReportDataSourceImpl>(),
        DataSourceType.hiveCache: Get.find<HiveSpamReportDataSourceImpl>()
      },
    ));
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
    Get.lazyPut(() => ServerSettingsRepositoryImpl(Get.find<ServerSettingsDataSource>()));
    Get.lazyPut(() => IdentityCreatorRepositoryImpl(
      Get.find<IdentityCreatorDataSource>()
    ));
    Get.lazyPut(() => AppGridRepositoryImpl({
      DataSourceType.network: Get.find<AppGridDatasource>(),
      DataSourceType.local: Get.find<LocalAppGridDatasourceImpl>()
    },));
  }
}