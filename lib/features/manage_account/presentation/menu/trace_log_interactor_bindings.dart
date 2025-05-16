import 'package:core/data/utils/device_manager.dart';
import 'package:core/utils/logger/log_tracking.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/trace_log_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/trace_log_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/trace_log_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/trace_log_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/export_trace_log_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/permissions/permission_service.dart';

class TraceLogInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<TraceLogDataSource>(() => Get.find<TraceLogDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => LogTracking());
    Get.lazyPut(() => TraceLogDataSourceImpl(
      Get.find<LogTracking>(),
      Get.find<DeviceManager>(),
      Get.find<PermissionService>(),
      Get.find<CacheExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => ExportTraceLogInteractor(Get.find<TraceLogRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<TraceLogRepository>(() => Get.find<TraceLogRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => TraceLogRepositoryImpl(Get.find<TraceLogDataSource>()));
  }

  void dispose() {
    Get.delete<ExportTraceLogInteractor>();
    Get.delete<TraceLogRepository>();
    Get.delete<TraceLogRepositoryImpl>();
    Get.delete<TraceLogDataSource>();
    Get.delete<TraceLogDataSourceImpl>();
    Get.delete<LogTracking>();
  }
}
