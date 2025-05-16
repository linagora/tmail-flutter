import 'package:tmail_ui_user/features/manage_account/data/datasource/trace_log_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/trace_log_repository.dart';

class TraceLogRepositoryImpl extends TraceLogRepository {
  final TraceLogDataSource _traceLogDataSource;

  TraceLogRepositoryImpl(this._traceLogDataSource);

  @override
  Future<String> exportTraceLog() {
    return _traceLogDataSource.exportTraceLog();
  }
}