import 'package:contact/contact_module.dart';
import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/auto_complete_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/composer_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_as_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/update_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/session_extension.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
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
import 'package:jmap_dart_client/http/http_client.dart' as jmap_http_client;
import 'package:worker_manager/worker_manager.dart';

class ComposerBindings extends BaseBindings {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final Set<AutoCompleteDataSource> dataSources = {};

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
    if (mailboxDashBoardController.sessionCurrent?.hasSupportAutoComplete == true) {
      Get.lazyPut(() => ContactAPI(Get.find<jmap_http_client.HttpClient>()));
      Get.lazyPut(() => TMailContactDataSourceImpl(Get.find<ContactAPI>()));
      dataSources.add(Get.find<TMailContactDataSourceImpl>());
    }

    Get.lazyPut(() => AttachmentUploadDataSourceImpl(Get.find<FileUploader>()));
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
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<ManageAccountDataSource>(() => Get.find<ManageAccountDataSourceImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ComposerRepositoryImpl(Get.find<AttachmentUploadDataSource>()));
    Get.lazyPut(() => AutoCompleteRepositoryImpl(dataSources));
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
    Get.lazyPut<AutoCompleteRepository>(() => Get.find<AutoCompleteRepositoryImpl>());
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut<EmailRepository>(() => Get.find<EmailRepositoryImpl>());
    Get.lazyPut<ManageAccountRepository>(() => Get.find<ManageAccountRepositoryImpl>());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.lazyPut(() => GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
    Get.lazyPut(() => GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()
    ));
    Get.lazyPut(() => LocalFilePickerInteractor());
    Get.lazyPut(() => UploadAttachmentInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => SendEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveEmailAsDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => UpdateEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetAllIdentitiesInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => RemoveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
    Get.lazyPut(() => SaveComposerCacheOnWebInteractor(Get.find<ComposerCacheRepository>()));
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => UploadController(Get.find<UploadAttachmentInteractor>()));
    Get.lazyPut(() => ComposerController(
        Get.find<SendEmailInteractor>(),
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetAutoCompleteWithDeviceContactInteractor>(),
        Get.find<DeviceInfoPlugin>(),
        Get.find<LocalFilePickerInteractor>(),
        Get.find<SaveEmailAsDraftsInteractor>(),
        Get.find<GetEmailContentInteractor>(),
        Get.find<UpdateEmailDraftsInteractor>(),
        Get.find<GetAllIdentitiesInteractor>(),
        Get.find<UploadController>(),
        Get.find<RemoveComposerCacheOnWebInteractor>(),
        Get.find<SaveComposerCacheOnWebInteractor>(),
    ));
  }

  void dispose() {
    Get.delete<UploadController>();
    Get.delete<ComposerController>();
  }
}