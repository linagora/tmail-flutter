
import 'package:contact/data/datasource_impl/tmail_contact_datasource_impl.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/repository/auto_complete_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';

class TMailAutoCompleteBindings extends BaseBindings {

  @override
  void bindingsController() {}

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {
    Get.put(TMailContactDataSourceImpl(Get.find<ContactAPI>()));
  }

  @override
  void bindingsInteractor() {
    Get.put(GetAutoCompleteInteractor(Get.find<AutoCompleteRepository>()));
    Get.put(GetAutoCompleteWithDeviceContactInteractor(
        Get.find<GetAutoCompleteInteractor>(),
        Get.find<GetDeviceContactSuggestionsInteractor>()
    ));
  }

  @override
  void bindingsRepository() {
    Get.put<AutoCompleteRepository>(Get.find<AutoCompleteRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(AutoCompleteRepositoryImpl({Get.find<TMailContactDataSourceImpl>()}));
  }
}