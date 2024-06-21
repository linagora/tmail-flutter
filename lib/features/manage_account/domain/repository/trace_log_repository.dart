import 'package:core/utils/log_tracking.dart';

abstract class TraceLogRepository {
  Future<TraceLog> getTraceLog();

  Future<String> exportTraceLog(TraceLog traceLog);
}