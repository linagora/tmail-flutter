import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/composer_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_as_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/update_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/attachment_upload_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:worker_manager/worker_manager.dart';

class ComposerBindings extends BaseBindings {

  @override
  void dependencies() {
    _bindingsUtils();
    super.dependencies();
  }

  void _bindingsUtils() {
    Get.lazyPut(() => FileUploader(Get.find<DioClient>(), Get.find<Executor>()));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AttachmentUploadDataSourceImpl(Get.find<FileUploader>()));
    Get.lazyPut(() => ComposerDataSourceImpl(Get.find<DownloadClient>()));
    Get.lazyPut(() => ContactDataSourceImpl());
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<DioClient>()
    ));
    Get.lazyPut(() => ManageAccountDataSourceImpl(
        Get.find<ManageAccountAPI>(),
        Get.find<LanguageCacheManager>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AttachmentUploadDataSource>(() => Get.find<AttachmentUploadDataSourceImpl>());
    Get.lazyPut<ComposerDataSource>(() => Get.find<ComposerDataSourceImpl>());
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<ManageAccountDataSource>(() => Get.find<ManageAccountDataSourceImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ComposerRepositoryImpl(
        Get.find<AttachmentUploadDataSource>(),
        Get.find<ComposerDataSource>()));
    Get.lazyPut(() => ContactRepositoryImpl(Get.find<ContactDataSource>()));
    Get.lazyPut(() => EmailRepositoryImpl(
        Get.find<EmailDataSource>(),
        Get.find<HtmlDataSource>()
    ));
    Get.lazyPut(() => ManageAccountRepositoryImpl(Get.find<ManageAccountDataSource>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ComposerRepository>(() => Get.find<ComposerRepositoryImpl>());
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<ManageAccountRepository>(() => Get.find<ManageAccountRepositoryImpl>());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => LocalFilePickerInteractor());
    Get.lazyPut(() => UploadAttachmentInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => SendEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveEmailAsDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => UpdateEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetAllIdentitiesInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => RemoveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => SaveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => DownloadImageAsBase64Interactor(Get.find<ComposerRepository>()));
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => RichTextMobileTabletController());
    Get.lazyPut(() => UploadController(Get.find<UploadAttachmentInteractor>()));
    Get.lazyPut(() => RichTextWebController());
    Get.lazyPut(() => ComposerController(
        Get.find<SendEmailInteractor>(),
        Get.find<DeviceInfoPlugin>(),
        Get.find<LocalFilePickerInteractor>(),
        Get.find<SaveEmailAsDraftsInteractor>(),
        Get.find<GetEmailContentInteractor>(),
        Get.find<UpdateEmailDraftsInteractor>(),
        Get.find<GetAllIdentitiesInteractor>(),
        Get.find<UploadController>(),
        Get.find<RemoveComposerCacheOnWebInteractor>(),
        Get.find<SaveComposerCacheOnWebInteractor>(),
        Get.find<RichTextWebController>(),
        Get.find<DownloadImageAsBase64Interactor>(),
    ));
  }

  void dispose() {
    Get.delete<UploadController>();
    Get.delete<RichTextWebController>();
    Get.delete<ComposerController>();
  }
}