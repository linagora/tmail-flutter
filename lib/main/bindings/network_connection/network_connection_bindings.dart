import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/network_status_handle/presentation/network_connnection_controller.dart';

class NetWorkConnectionBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.put(NetworkConnectionController(Get.find<Connectivity>()));
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }
}