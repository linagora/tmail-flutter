import 'package:core/core.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/autocomplete_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/autocomplete_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/local_autocomplete_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/local_composer_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/local/email_address_database_manager.dart';
import 'package:tmail_ui_user/features/composer/data/repository/auto_complete_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/composer_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_addresses_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:uuid/uuid.dart';

class ComposerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailAddressDatabaseManager(Get.find<DatabaseClient>()));
    Get.lazyPut(() => ComposerDataSourceImpl());
    Get.lazyPut(() => LocalComposerDataSourceImpl(Get.find<EmailAddressDatabaseManager>()));
    Get.lazyPut<ComposerDataSource>(() => Get.find<ComposerDataSourceImpl>());
    Get.lazyPut(() => ComposerRepositoryImpl({
      DataSourceType.network: Get.find<ComposerDataSource>(),
      DataSourceType.local: Get.find<LocalComposerDataSourceImpl>(),
    }));
    Get.lazyPut<ComposerRepository>(() => Get.find<ComposerRepositoryImpl>());
    Get.lazyPut(() => SendEmailInteractor(Get.find<EmailRepository>()));
    Get.lazyPut(() => SaveEmailAddressesInteractor(Get.find<ComposerRepository>()));
    Get.lazyPut(() => AutoCompleteDataSourceImpl());
    Get.lazyPut<AutoCompleteDataSource>(() => Get.find<AutoCompleteDataSourceImpl>());
    Get.lazyPut(() => LocalAutoCompleteDataSourceImpl(Get.find<EmailAddressDatabaseManager>()));
    Get.lazyPut(() => AutoCompleteRepositoryImpl({
      DataSourceType.network: Get.find<AutoCompleteDataSource>(),
      DataSourceType.local: Get.find<LocalAutoCompleteDataSourceImpl>(),
    }));
    Get.lazyPut<AutoCompleteRepository>(() => Get.find<AutoCompleteRepositoryImpl>());
    Get.lazyPut(() => GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.lazyPut(() => Uuid());
    Get.lazyPut(() => HtmlEditorController());
    Get.lazyPut(() => TextEditingController());
    Get.lazyPut(() => ContactDataSourceImpl());
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
    Get.lazyPut(() => ContactRepositoryImpl(Get.find<ContactDataSource>()));
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut(() => GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
    Get.lazyPut(() => GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()));
    Get.lazyPut(() => ComposerController(
      Get.find<SendEmailInteractor>(),
      Get.find<SaveEmailAddressesInteractor>(),
      Get.find<GetAutoCompleteInteractor>(),
      Get.find<GetAutoCompleteWithDeviceContactInteractor>(),
      Get.find<AppToast>(),
      Get.find<Uuid>(),
      Get.find<HtmlEditorController>(),
      Get.find<TextEditingController>(),
      Get.find<HtmlMessagePurifier>()));
  }
}