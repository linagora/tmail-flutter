import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/autocomplete_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/autocomplete_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/local_autocomplete_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/local_composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/local/email_address_database_manager.dart';
import 'package:tmail_ui_user/features/composer/data/network/composer_api.dart';
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
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_addresses_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_mutiple_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/repository/email_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:uuid/uuid.dart';
import 'package:jmap_dart_client/http/http_client.dart' as jmap_http_client;

class ComposerBindings extends BaseBindings {
  @override
  void dependencies() {
    _bindingsUtils();
    super.dependencies();
  }

  void _bindingsUtils() {
    Get.lazyPut(() => EmailAddressDatabaseManager(Get.find<DatabaseClient>()));
    Get.lazyPut(() => const Uuid());
    Get.lazyPut(() => ManageAccountAPI(Get.find<jmap_http_client.HttpClient>()));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => ComposerDataSourceImpl(Get.find<ComposerAPI>()));
    Get.lazyPut(() => LocalComposerDataSourceImpl(Get.find<EmailAddressDatabaseManager>()));
    Get.lazyPut(() => AutoCompleteDataSourceImpl());
    Get.lazyPut(() => LocalAutoCompleteDataSourceImpl(Get.find<EmailAddressDatabaseManager>()));
    Get.lazyPut(() => ContactDataSourceImpl());
    Get.lazyPut(() => EmailDataSourceImpl(Get.find<EmailAPI>()));
    Get.lazyPut(() => HtmlDataSourceImpl(
        Get.find<HtmlAnalyzer>(),
        Get.find<DioClient>()
    ));
    Get.lazyPut(() => ManageAccountDataSourceImpl(Get.find<ManageAccountAPI>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ComposerDataSource>(() => Get.find<ComposerDataSourceImpl>());
    Get.lazyPut<AutoCompleteDataSource>(() => Get.find<AutoCompleteDataSourceImpl>());
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
    Get.lazyPut<EmailDataSource>(() => Get.find<EmailDataSourceImpl>());
    Get.lazyPut<HtmlDataSource>(() => Get.find<HtmlDataSourceImpl>());
    Get.lazyPut<ManageAccountDataSource>(() => Get.find<ManageAccountDataSourceImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => ComposerRepositoryImpl({
      DataSourceType.network: Get.find<ComposerDataSource>(),
      DataSourceType.local: Get.find<LocalComposerDataSourceImpl>(),
    }));
    Get.lazyPut(() => AutoCompleteRepositoryImpl({
      DataSourceType.network: Get.find<AutoCompleteDataSource>(),
      DataSourceType.local: Get.find<LocalAutoCompleteDataSourceImpl>(),
    }));
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
    Get.lazyPut(() => SaveEmailAddressesInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.lazyPut(() => GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
    Get.lazyPut(() => GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()
    ));
    Get.lazyPut(() => LocalFilePickerInteractor());
    Get.lazyPut(() => UploadAttachmentInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => UploadMultipleAttachmentInteractor(Get.find<UploadAttachmentInteractor>()));
    Get.lazyPut(() => SendEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveEmailAsDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetEmailContentInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => UpdateEmailDraftsInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => GetAllIdentitiesInteractor(Get.find<ManageAccountRepository>()));
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => ComposerController(
        Get.find<SendEmailInteractor>(),
        Get.find<SaveEmailAddressesInteractor>(),
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetAutoCompleteWithDeviceContactInteractor>(),
        Get.find<Uuid>(),
        Get.find<DeviceInfoPlugin>(),
        Get.find<LocalFilePickerInteractor>(),
        Get.find<UploadMultipleAttachmentInteractor>(),
        Get.find<SaveEmailAsDraftsInteractor>(),
        Get.find<GetEmailContentInteractor>(),
        Get.find<UpdateEmailDraftsInteractor>(),
        Get.find<GetAllIdentitiesInteractor>(),
    ));
  }
}