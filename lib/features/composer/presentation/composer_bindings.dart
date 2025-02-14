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
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/session_storage_composer_datasoure_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_interactors_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/attachment_upload_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';
import 'package:uuid/uuid.dart';

class ComposerBindings extends BaseBindings {

  final String? composerId;
  final ComposerArguments? composerArguments;

  ComposerBindings({this.composerId, this.composerArguments});

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
      () => ComposerCacheRepositoryImpl(Get.find<SessionStorageComposerDatasource>(tag: composerId)),
      tag: composerId,
    );
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
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ComposerRepository>(
      () => Get.find<ComposerRepositoryImpl>(tag: composerId),
      tag: composerId,
    );
    Get.lazyPut<ComposerCacheRepository>(
      () => Get.find<ComposerCacheRepositoryImpl>(tag: composerId),
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
    PreferencesInteractorsBindings().dependencies();
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
      Get.find<GetServerSettingInteractor>(tag: composerId),
      Get.find<CreateNewAndSendEmailInteractor>(tag: composerId),
      Get.find<CreateNewAndSaveEmailToDraftsInteractor>(tag: composerId),
      Get.find<PrintEmailInteractor>(tag: composerId),
      composerId: composerId,
      composerArgs: composerArguments,
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

    Get.delete<AttachmentUploadDataSourceImpl>(tag: composerId);
    Get.delete<ComposerDataSourceImpl>(tag: composerId);
    Get.delete<ContactDataSourceImpl>(tag: composerId);
    Get.delete<MailboxDataSourceImpl>(tag: composerId);
    Get.delete<MailboxCacheDataSourceImpl>(tag: composerId);
    Get.delete<EmailDataSourceImpl>(tag: composerId);
    Get.delete<HtmlDataSourceImpl>(tag: composerId);
    Get.delete<StateDataSourceImpl>(tag: composerId);
    Get.delete<PrintFileDataSourceImpl>(tag: composerId);
    Get.delete<EmailHiveCacheDataSourceImpl>(tag: composerId);
    Get.delete<EmailLocalStorageDataSourceImpl>(tag: composerId);
    Get.delete<EmailSessionStorageDatasourceImpl>(tag: composerId);
    Get.delete<RemoteServerSettingsDataSourceImpl>(tag: composerId);
    Get.delete<SessionStorageComposerDatasourceImpl>(tag: composerId);

    Get.delete<AttachmentUploadDataSource>(tag: composerId);
    Get.delete<ComposerDataSource>(tag: composerId);
    Get.delete<ContactDataSource>(tag: composerId);
    Get.delete<MailboxDataSource>(tag: composerId);
    Get.delete<EmailDataSource>(tag: composerId);
    Get.delete<HtmlDataSource>(tag: composerId);
    Get.delete<StateDataSource>(tag: composerId);
    Get.delete<PrintFileDataSource>(tag: composerId);
    Get.delete<ServerSettingsDataSource>(tag: composerId);
    Get.delete<SessionStorageComposerDatasource>(tag: composerId);

    Get.delete<ComposerRepositoryImpl>(tag: composerId);
    Get.delete<ComposerCacheRepositoryImpl>(tag: composerId);
    Get.delete<ContactRepositoryImpl>(tag: composerId);
    Get.delete<MailboxRepositoryImpl>(tag: composerId);
    Get.delete<EmailRepositoryImpl>(tag: composerId);
    Get.delete<ServerSettingsRepositoryImpl>(tag: composerId);

    Get.delete<ComposerRepository>(tag: composerId);
    Get.delete<ComposerCacheRepository>(tag: composerId);
    Get.delete<ContactRepository>(tag: composerId);
    Get.delete<MailboxRepository>(tag: composerId);
    Get.delete<EmailRepository>(tag: composerId);
    Get.delete<ServerSettingsRepository>(tag: composerId);

    Get.delete<LocalFilePickerInteractor>(tag: composerId);
    Get.delete<LocalImagePickerInteractor>(tag: composerId);
    Get.delete<UploadAttachmentInteractor>(tag: composerId);
    Get.delete<GetEmailContentInteractor>(tag: composerId);
    Get.delete<RemoveComposerCacheOnWebInteractor>(tag: composerId);
    Get.delete<SaveComposerCacheOnWebInteractor>(tag: composerId);
    Get.delete<DownloadImageAsBase64Interactor>(tag: composerId);
    Get.delete<TransformHtmlEmailContentInteractor>(tag: composerId);
    Get.delete<GetAlwaysReadReceiptSettingInteractor>(tag: composerId);
    Get.delete<CreateNewAndSendEmailInteractor>(tag: composerId);
    Get.delete<CreateNewAndSaveEmailToDraftsInteractor>(tag: composerId);
    Get.delete<RestoreEmailInlineImagesInteractor>(tag: composerId);
    Get.delete<PrintEmailInteractor>(tag: composerId);

    Get.delete<FileUploader>(tag: composerId);

    IdentityInteractorsBindings().dispose();
  }
}