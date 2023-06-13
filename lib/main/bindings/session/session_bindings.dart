import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/data/datasource_impl/hive_session_datasource_impl.dart';
import 'package:tmail_ui_user/features/session/data/datasource_impl/session_datasource_impl.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';
import 'package:tmail_ui_user/features/session/data/repository/session_repository_impl.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class SessionBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.put<SessionDataSource>(Get.find<SessionDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.put(SessionDataSourceImpl(
      Get.find<SessionAPI>(),
      Get.find<RemoteExceptionThrower>()));
    Get.put(HiveSessionDataSourceImpl(
      Get.find<SessionHiveCacheClient>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.put(GetSessionInteractor(Get.find<SessionRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.put<SessionRepository>(Get.find<SessionRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(SessionRepositoryImpl({
      DataSourceType.network: Get.find<SessionDataSource>(),
      DataSourceType.hiveCache: Get.find<HiveSessionDataSourceImpl>(),
    }));
  }
}