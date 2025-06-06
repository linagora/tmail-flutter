
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:get/get.dart';
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
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class EmailPreviewerBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => EmailPreviewerController(
        Get.find<GetPreviewEmailEMLContentSharedInteractor>(),
        Get.find<MovePreviewEmlContentFromPersistentToMemoryInteractor>(),
        Get.find<RemovePreviewEmailEmlContentSharedInteractor>(),
        Get.find<GetPreviewEmlContentInMemoryInteractor>(),
        Get.find<ParseEmailByBlobIdInteractor>(),
        Get.find<PreviewEmailFromEmlFileInteractor>(),
        Get.find<DownloadAttachmentForWebInteractor>(),
        Get.find<DownloadManager>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<PrintFileDataSource>(() => Get.find<PrintFileDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => EmailDataSourceImpl(
        Get.find<EmailAPI>(),
        Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => StateDataSourceImpl(
        Get.find<StateCacheManager>(),
        Get.find<IOSSharingManager>(),
        Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => PrintFileDataSourceImpl(
        Get.find<PrintUtils>(),
        Get.find<ImagePaths>(),
        Get.find<FileUtils>(),
        Get.find<HtmlAnalyzer>(),
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
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetPreviewEmailEMLContentSharedInteractor(
        Get.find<EmailRepository>()));
    Get.lazyPut(() => MovePreviewEmlContentFromPersistentToMemoryInteractor(
        Get.find<EmailRepository>()));
    Get.lazyPut(() => RemovePreviewEmailEmlContentSharedInteractor(
        Get.find<EmailRepository>()));
    Get.lazyPut(() => GetPreviewEmlContentInMemoryInteractor(
        Get.find<EmailRepository>()));
    Get.lazyPut(() => ParseEmailByBlobIdInteractor(
        Get.find<EmailRepository>()));
    Get.lazyPut(() => PreviewEmailFromEmlFileInteractor(
        Get.find<EmailRepository>()));
    Get.lazyPut(() => DownloadAttachmentForWebInteractor(
        Get.find<EmailRepository>(),
        Get.find<CredentialRepository>(),
        Get.find<AccountRepository>(),
        Get.find<AuthenticationOIDCRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
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
        Get.find<PrintFileDataSource>()));
  }
}