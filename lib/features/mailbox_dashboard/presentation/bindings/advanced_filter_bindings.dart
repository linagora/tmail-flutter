import 'package:contact/contact_module.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/auto_complete_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:jmap_dart_client/http/http_client.dart' as jmap_http_client;

class AdvancedFilterBindings extends BaseBindings {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final Set<AutoCompleteDataSource> dataSources = {};

  @override
  void bindingsDataSourceImpl() {
    if (mailboxDashBoardController.sessionCurrent?.hasSupportAutoComplete == true) {
      Get.lazyPut(() => ContactAPI(Get.find<jmap_http_client.HttpClient>()));
      Get.lazyPut(() => TMailContactDataSourceImpl(Get.find<ContactAPI>()));
      dataSources.add(Get.find<TMailContactDataSourceImpl>());
    }

    Get.lazyPut(() => ContactDataSourceImpl());
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => AutoCompleteRepositoryImpl(dataSources));
    Get.lazyPut(() => ContactRepositoryImpl(Get.find<ContactDataSource>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<AutoCompleteRepository>(() => Get.find<AutoCompleteRepositoryImpl>());
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.lazyPut(() => GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
    Get.lazyPut(() => GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()
    ));
  }

  @override
  void bindingsController() {
  }
}