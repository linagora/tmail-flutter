
import 'package:contact/data/datasource/auto_complete_datasource.dart';
import 'package:contact/data/datasource_impl/tmail_contact_datasource_impl.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/auto_complete_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class AutoCompleteBindings extends BaseBindings {

  final _mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final Set<AutoCompleteDataSource> _dataSources = {};

  @override
  void bindingsController() {}

  @override
  void bindingsDataSource() {
    Get.lazyPut<ContactDataSource>(() => Get.find<ContactDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    _dataSources.clear();
    Get.lazyPut(() => ContactDataSourceImpl());
    if (_mailboxDashBoardController.sessionCurrent?.hasSupportAutoComplete == true) {
      Get.lazyPut(() => TMailContactDataSourceImpl(Get.find<ContactAPI>()));
      _dataSources.add(Get.find<TMailContactDataSourceImpl>());
    }
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
    Get.lazyPut(() => GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.lazyPut(() => GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<ContactRepository>(() => Get.find<ContactRepositoryImpl>());
    Get.lazyPut<AutoCompleteRepository>(() => Get.find<AutoCompleteRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    log('AutoCompleteBindings::bindingsRepositoryImpl(): _dataSources: ${_dataSources.length}');
    Get.lazyPut(() => ContactRepositoryImpl(Get.find<ContactDataSource>()));
    Get.lazyPut(() => AutoCompleteRepositoryImpl(_dataSources));
  }
}