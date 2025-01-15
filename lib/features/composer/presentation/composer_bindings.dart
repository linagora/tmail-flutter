import 'package:core/core.dart';
import 'package:core/utils/application_manager.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/composer_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/restore_email_inline_images_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
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
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource_impl/remote_server_settings_data_source_impl.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/data/repository/server_settings_repository_impl.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/attachment_upload_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:worker_manager/worker_manager.dart';

class ComposerBindings extends BaseBindings {

  @override
  void dependencies() {
    _bindingsUtils();
    super.dependencies();
  }

  void _bindingsUtils() {
    Get.lazyPut(() => FileUploader(
      Get.find<DioClient>(tag: BindingTag.isolateTag),
      Get.find<Executor>(),
      Get.find<FileUtils>(),
    ));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AttachmentUploadDataSourceImpl(
      Get.find<FileUploader>(),
      Get.find<Uuid>(),
      Get.find<RemoteExceptionThrower>()
    ));
    Get.lazyPut(() => ComposerDataSourceImpl(Get.find<DownloadClient>(), Get.find<RemoteExceptionThrower>()));
    Get.lazyPut(() => ContactDataSourceImpl(Get.find<CacheExceptionThrower>()));
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
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => EmailSessionStorageDatasourceImpl(
      Get.find<SessionStorageManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AttachmentUploadDataSource>(() => Get.find<AttachmentUploadDataSourceImpl>());
    Get.lazyPut<ComposerDataSource>(() => Get.find<ComposerDataSourceImpl>());
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
    Get.lazyPut<PrintFileDataSource>(() => Get.find<PrintFileDataSourceImpl>());
    Get.lazyPut<ServerSettingsDataSource>(
      () => Get.find<RemoteServerSettingsDataSourceImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ComposerRepositoryImpl(
      Get.find<AttachmentUploadDataSource>(),
      Get.find<ComposerDataSource>(),
      Get.find<HtmlDataSource>(),
      Get.find<ApplicationManager>(),
      Get.find<Uuid>(),
    ));
    Get.lazyPut(() => ContactRepositoryImpl(Get.find<ContactDataSource>()));
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
    Get.lazyPut(() => ServerSettingsRepositoryImpl(
      Get.find<ServerSettingsDataSource>(),
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ComposerRepository>(() => Get.find<ComposerRepositoryImpl>());
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<ServerSettingsRepository>(() => Get.find<ServerSettingsRepositoryImpl>());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => LocalFilePickerInteractor());
    Get.lazyPut(() => LocalImagePickerInteractor());
    Get.lazyPut(() => UploadAttachmentInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => RemoveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => SaveComposerCacheOnWebInteractor(
      Get.find<ComposerCacheRepository>(),
      Get.find<ComposerRepository>(),
    ));
    Get.lazyPut(() => DownloadImageAsBase64Interactor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => TransformHtmlEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetAlwaysReadReceiptSettingInteractor(Get.find<ServerSettingsRepository>()));
    Get.lazyPut(() => CreateNewAndSendEmailInteractor(
      Get.find<EmailRepository>(),
      Get.find<ComposerRepository>(),
    ));
    Get.lazyPut(() => CreateNewAndSaveEmailToDraftsInteractor(
      Get.find<EmailRepository>(),
      Get.find<ComposerRepository>(),
    ));
    Get.lazyPut(() => RestoreEmailInlineImagesInteractor(
      Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => PrintEmailInteractor(
      Get.find<EmailRepository>()));

    IdentityInteractorsBindings().dependencies();
  }

  @override
  void bindingsController() {
    if (PlatformInfo.isWeb) {
      Get.lazyPut(() => RichTextWebController());
    } else {
      Get.lazyPut(() => RichTextMobileTabletController());
    }
    Get.lazyPut(() => UploadController(Get.find<UploadAttachmentInteractor>()));
    Get.lazyPut(() => ComposerController(
      Get.find<LocalFilePickerInteractor>(),
      Get.find<LocalImagePickerInteractor>(),
      Get.find<GetEmailContentInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<UploadController>(),
      Get.find<RemoveComposerCacheOnWebInteractor>(),
      Get.find<SaveComposerCacheOnWebInteractor>(),
      Get.find<DownloadImageAsBase64Interactor>(),
      Get.find<TransformHtmlEmailContentInteractor>(),
      Get.find<GetAlwaysReadReceiptSettingInteractor>(),
      Get.find<CreateNewAndSendEmailInteractor>(),
      Get.find<CreateNewAndSaveEmailToDraftsInteractor>(),
      Get.find<PrintEmailInteractor>(),
    ));
  }

  void dispose() {
    if (PlatformInfo.isWeb) {
      Get.delete<RichTextWebController>();
    } else {
      Get.delete<RichTextMobileTabletController>();
    }
    Get.delete<UploadController>();
    Get.delete<ComposerController>();
  }
}