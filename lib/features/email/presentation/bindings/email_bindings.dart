import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
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
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_entire_message_as_document_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_stored_email_state_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
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
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class EmailBindings extends BaseBindings {
  final EmailId? currentEmailId;

  EmailBindings({this.currentEmailId});

  String? get tag => currentEmailId?.id.value;

  @override
  void bindingsController() {
    Get.put(SingleEmailController(
      Get.find<GetEmailContentInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<DownloadAttachmentsInteractor>(),
      Get.find<DeviceManager>(),
      Get.find<ExportAttachmentInteractor>(),
      Get.find<MarkAsStarEmailInteractor>(),
      Get.find<DownloadAttachmentForWebInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<StoreOpenedEmailInteractor>(),
      Get.find<PrintEmailInteractor>(),
      Get.find<ParseEmailByBlobIdInteractor>(),
      Get.find<PreviewEmailFromEmlFileInteractor>(),
      Get.find<GetHtmlContentFromAttachmentInteractor>(),
      Get.find<DownloadAllAttachmentsForWebInteractor>(),
      Get.find<ExportAllAttachmentsInteractor>(),
      currentEmailId: currentEmailId,
    ), tag: tag);
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<PrintFileDataSource>(() => Get.find<PrintFileDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => MailboxDataSourceImpl(
      Get.find<MailboxAPI>(),
      Get.find<MailboxIsolateWorker>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => MailboxCacheDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailDataSourceImpl(
      Get.find<EmailAPI>(),
      Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>()));
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
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsEmailReadInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DownloadAttachmentsInteractor(
        Get.find<EmailRepository>(),
        Get.find<CredentialRepository>(),
        Get.find<AccountRepository>(),
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<AuthorizationInterceptors>(),
    ));
    Get.lazyPut(() => ExportAttachmentInteractor(
        Get.find<EmailRepository>(),
        Get.find<CredentialRepository>(),
        Get.find<AccountRepository>(),
        Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => MoveToMailboxInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => MarkAsStarEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => DownloadAttachmentForWebInteractor(
      Get.find<EmailRepository>(),
      Get.find<CredentialRepository>(),
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>()));
    Get.lazyPut(() => GetStoredEmailStateInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => StoreOpenedEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => PrintEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => ParseEmailByBlobIdInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => PreviewEmailFromEmlFileInteractor(Get.find<EmailRepository>()));
    IdentityInteractorsBindings().dependencies();
    Get.lazyPut(() => GetHtmlContentFromAttachmentInteractor(Get.find<DownloadAttachmentForWebInteractor>()));
    Get.lazyPut(() => DownloadAllAttachmentsForWebInteractor(
      Get.find<EmailRepository>(),
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>()));
    Get.lazyPut(() => ExportAllAttachmentsInteractor(
      Get.find<EmailRepository>(),
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>()));
    if (PlatformInfo.isIOS) {
      Get.lazyPut(() => GetEntireMessageAsDocumentInteractor(
        Get.find<EmailRepository>(),
      ));
    }
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
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
  }
}