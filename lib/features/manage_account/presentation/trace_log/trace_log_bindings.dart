import 'package:core/core.dart';
import 'package:core/data/utils/device_manager.dart';
import 'package:core/utils/log_tracking.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/trace_log_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/trace_log_data_source_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/trace_log_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/trace_log_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_trace_log_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/export_trace_log_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_trace_log_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/trace_log/trace_log_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/permissions/permission_service.dart';

class TraceLogBindings extends BaseBindings {
  @override
  void bindingsController() {
    Get.lazyPut(() => TraceLogController(
      Get.find<GetTraceLogInteractor>(),
      Get.find<ExportTraceLogInteractor>(),
      Get.find<DeleteTraceLogInteractor>()));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<TraceLogDataSource>(() => Get.find<TraceLogDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => TraceLogDataSourceImpl(
      LogTracking(),
      Get.find<DeviceManager>(),
      Get.find<PermissionService>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetTraceLogInteractor(Get.find<TraceLogRepository>()));
    Get.lazyPut(() => ExportTraceLogInteractor(Get.find<TraceLogRepository>()));
    Get.lazyPut(() => DeleteTraceLogInteractor(Get.find<TraceLogRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<TraceLogRepository>(() => Get.find<TraceLogRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => TraceLogRepositoryImpl(Get.find<TraceLogDataSource>()));
  }
}