
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/datasource_impl/contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/composer/data/repository/contact_repository_impl.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';

class ContactAutoCompleteBindings extends BaseBindings {

  @override
  void bindingsController() {}

  @override
  void bindingsDataSource() {
    Get.put<ContactDataSource>(Get.find<ContactDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.put(ContactDataSourceImpl());
  }

  @override
  void bindingsInteractor() {
    Get.put(GetDeviceContactSuggestionsInteractor(Get.find<ContactRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.put<ContactRepository>(Get.find<ContactRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(ContactRepositoryImpl(Get.find<ContactDataSource>()));
  }
}