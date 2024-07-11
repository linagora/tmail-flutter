import 'package:core/utils/log_tracking.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/trace_log_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/trace_log_repository.dart';

class TraceLogRepositoryImpl extends TraceLogRepository {
  final TraceLogDataSource _traceLogDataSource;

  TraceLogRepositoryImpl(this._traceLogDataSource);

  @override
  Future<TraceLog> getTraceLog() {
    return _traceLogDataSource.getTraceLog();
  }

  @override
  Future<String> exportTraceLog(TraceLog traceLog) {
    return _traceLogDataSource.exportTraceLog(traceLog);
  }

  @override
  Future<void> deleteTraceLog(String path) {
    return _traceLogDataSource.deleteTraceLog(path);
  }
}