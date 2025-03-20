import 'package:core/utils/log_tracking.dart';

abstract class TraceLogDataSource {
  Future<TraceLog> getTraceLog();

  Future<String> exportTraceLog(TraceLog traceLog);

  Future<void> deleteTraceLog(String path);
}