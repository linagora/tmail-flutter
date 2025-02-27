import 'package:core/core.dart';
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

  final String? composerId;

  ComposerBindings({this.composerId});

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
    ), tag: composerId);
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AttachmentUploadDataSourceImpl(
      Get.find<FileUploader>(tag: composerId),
      Get.find<Uuid>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => ComposerDataSourceImpl(
      Get.find<DownloadClient>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => ContactDataSourceImpl(
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => MailboxDataSourceImpl(
      Get.find<MailboxAPI>(),
      Get.find<MailboxIsolateWorker>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => MailboxCacheDataSourceImpl(
      Get.find<MailboxCacheManager>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => EmailDataSourceImpl(
      Get.find<EmailAPI>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => HtmlDataSourceImpl(
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => StateDataSourceImpl(
      Get.find<StateCacheManager>(),
      Get.find<IOSSharingManager>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => PrintFileDataSourceImpl(
      Get.find<PrintUtils>(),
      Get.find<ImagePaths>(),
      Get.find<FileUtils>(),
      Get.find<HtmlAnalyzer>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => EmailHiveCacheDataSourceImpl(
      Get.find<NewEmailCacheManager>(),
      Get.find<OpenedEmailCacheManager>(),
      Get.find<NewEmailCacheWorkerQueue>(),
      Get.find<OpenedEmailCacheWorkerQueue>(),
      Get.find<EmailCacheManager>(),
      Get.find<SendingEmailCacheManager>(),
      Get.find<FileUtils>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => EmailLocalStorageDataSourceImpl(
      Get.find<LocalStorageManager>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => EmailSessionStorageDatasourceImpl(
      Get.find<SessionStorageManager>(),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
    Get.lazyPut(() => RemoteServerSettingsDataSourceImpl(
      Get.find<ServerSettingsAPI>(),
      Get.find<RemoteExceptionThrower>(),
    ), tag: composerId);
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AttachmentUploadDataSource>(
      () => Get.find<AttachmentUploadDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ComposerDataSource>(
      () => Get.find<ComposerDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ContactDataSource>(
      () => Get.find<ContactDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<MailboxDataSource>(
      () => Get.find<MailboxDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<EmailDataSource>(
      () => Get.find<EmailDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<HtmlDataSource>(
      () => Get.find<HtmlDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<StateDataSource>(
      () => Get.find<StateDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<PrintFileDataSource>(
      () => Get.find<PrintFileDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ServerSettingsDataSource>(
      () => Get.find<RemoteServerSettingsDataSourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ComposerRepositoryImpl(
      Get.find<AttachmentUploadDataSource>(tag: composerId),
      Get.find<ComposerDataSource>(tag: composerId),
      Get.find<HtmlDataSource>(tag: composerId),
      Get.find<ApplicationManager>(),
      Get.find<Uuid>(),
    ), tag: composerId);
    Get.lazyPut(
      () => ContactRepositoryImpl(Get.find<ContactDataSource>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(tag: composerId),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>(tag: composerId)
      },
      Get.find<StateDataSource>(tag: composerId),
    ), tag: composerId);
    Get.lazyPut(() => EmailRepositoryImpl(
      {
        DataSourceType.network: Get.find<EmailDataSource>(tag: composerId),
        DataSourceType.hiveCache: Get.find<EmailHiveCacheDataSourceImpl>(tag: composerId),
        DataSourceType.local: Get.find<EmailLocalStorageDataSourceImpl>(tag: composerId),
        DataSourceType.session: Get.find<EmailSessionStorageDatasourceImpl>(tag: composerId),
      },
      Get.find<HtmlDataSource>(tag: composerId),
      Get.find<StateDataSource>(tag: composerId),
      Get.find<PrintFileDataSource>(tag: composerId),
    ), tag: composerId);
    Get.lazyPut(() => ServerSettingsRepositoryImpl(
      Get.find<ServerSettingsDataSource>(tag: composerId),
    ), tag: composerId);
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ComposerRepository>(
      () => Get.find<ComposerRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ContactRepository>(
      () => Get.find<ContactRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<MailboxRepository>(
      () => Get.find<MailboxRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<EmailRepository>(
      () => Get.find<EmailRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ServerSettingsRepository>(
      () => Get.find<ServerSettingsRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => LocalFilePickerInteractor(),
      tag: composerId,
    );
    Get.lazyPut(
      () => LocalImagePickerInteractor(),
      tag: composerId,
    );
    Get.lazyPut(
      () => UploadAttachmentInteractor(Get.find<ComposerRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => GetEmailContentInteractor(Get.find<EmailRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => RemoveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(() => SaveComposerCacheOnWebInteractor(
      Get.find<ComposerCacheRepository>(tag: composerId),
      Get.find<ComposerRepository>(tag: composerId),
    ), tag: composerId);
    Get.lazyPut(
      () => DownloadImageAsBase64Interactor(Get.find<ComposerRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => TransformHtmlEmailContentInteractor(Get.find<EmailRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => GetAlwaysReadReceiptSettingInteractor(Get.find<ServerSettingsRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(() => CreateNewAndSendEmailInteractor(
      Get.find<EmailRepository>(tag: composerId),
      Get.find<ComposerRepository>(tag: composerId),
    ), tag: composerId);
    Get.lazyPut(() => CreateNewAndSaveEmailToDraftsInteractor(
      Get.find<EmailRepository>(tag: composerId),
      Get.find<ComposerRepository>(tag: composerId),
    ), tag: composerId);
    Get.lazyPut(
      () => RestoreEmailInlineImagesInteractor(Get.find<ComposerCacheRepository>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(
      () => PrintEmailInteractor(Get.find<EmailRepository>(tag: composerId)),
      tag: composerId,
    );

    IdentityInteractorsBindings(composerId: composerId).dependencies();
  }

  @override
  void bindingsController() {
    if (PlatformInfo.isWeb) {
      Get.lazyPut(() => RichTextWebController(), tag: composerId);
    } else {
      Get.lazyPut(() => RichTextMobileTabletController(), tag: composerId);
    }
    Get.lazyPut(
      () => UploadController(Get.find<UploadAttachmentInteractor>(tag: composerId)),
      tag: composerId,
    );
    Get.lazyPut(() => ComposerController(
      Get.find<LocalFilePickerInteractor>(tag: composerId),
      Get.find<LocalImagePickerInteractor>(tag: composerId),
      Get.find<GetEmailContentInteractor>(tag: composerId),
      Get.find<GetAllIdentitiesInteractor>(tag: composerId),
      Get.find<UploadController>(tag: composerId),
      Get.find<RemoveComposerCacheOnWebInteractor>(tag: composerId),
      Get.find<SaveComposerCacheOnWebInteractor>(tag: composerId),
      Get.find<DownloadImageAsBase64Interactor>(tag: composerId),
      Get.find<TransformHtmlEmailContentInteractor>(tag: composerId),
      Get.find<GetAlwaysReadReceiptSettingInteractor>(tag: composerId),
      Get.find<CreateNewAndSendEmailInteractor>(tag: composerId),
      Get.find<CreateNewAndSaveEmailToDraftsInteractor>(tag: composerId),
      Get.find<PrintEmailInteractor>(tag: composerId),
    ), tag: composerId);
  }

  void dispose() {
    if (PlatformInfo.isWeb) {
      Get.delete<RichTextWebController>(tag: composerId);
    } else {
      Get.delete<RichTextMobileTabletController>(tag: composerId);
    }
    Get.delete<UploadController>(tag: composerId);
    Get.delete<ComposerController>(tag: composerId);
  }
}