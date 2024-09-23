import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/remote_web_socket_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/web_socket_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/web_socket_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/connect_web_socket_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class WebSocketInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<WebSocketDatasource>(() => Get.find<RemoteWebSocketDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RemoteWebSocketDatasourceImpl(
      Get.find<WebSocketApi>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => ConnectWebSocketInteractor(Get.find<WebSocketRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<WebSocketRepository>(() => Get.find<WebSocketRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => WebSocketRepositoryImpl(Get.find<WebSocketDatasource>()));
  }
}