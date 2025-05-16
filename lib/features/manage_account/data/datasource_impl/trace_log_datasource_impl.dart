
import 'package:core/data/utils/device_manager.dart';
import 'package:core/domain/exceptions/file_exception.dart';
import 'package:core/utils/logger/log_tracking.dart';
import 'package:core/utils/platform_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/trace_log_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/permission_exception.dart';
import 'package:tmail_ui_user/main/permissions/permission_service.dart';

class TraceLogDataSourceImpl extends TraceLogDataSource {

  final LogTracking _logTracking;
  final DeviceManager _deviceManager;
  final PermissionService _permissionService;
  final ExceptionThrower _exceptionThrower;

  TraceLogDataSourceImpl(
    this._logTracking,
    this._deviceManager,
    this._permissionService,
    this._exceptionThrower,
  );

  @override
  Future<String> exportTraceLog() {
    return Future.sync(() async {
      if (PlatformInfo.isAndroid) {
        final permissionGranted = await _validateStoragePermissionOnAndroid();
        if (permissionGranted) {
          final traceLog = await _logTracking.getTraceLog();
          return await _logTracking.exportTraceLog(traceLog);
        } else {
          throw const NotGrantedPermissionStorageException();
        }
      } else {
        final traceLog = await _logTracking.getTraceLog();
        final savePath = await _logTracking.exportTraceLog(traceLog);
        final result = await Share.shareXFiles([XFile(savePath)]);
        if (result.status == ShareResultStatus.success) {
          return savePath;
        }
        throw UserCancelShareFileException();
      }
    }).catchError(_exceptionThrower.throwException);
  }

  Future<bool> _validateStoragePermissionOnAndroid() async {
    final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();
    if (needRequestPermission) {
      final isGranted = await _permissionService.isGranted(Permission.storage);
      return isGranted;
    } else {
      return true;
    }
  }
}