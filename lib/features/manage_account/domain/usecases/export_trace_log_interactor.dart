import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/trace_log_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/export_trace_log_state.dart';

class ExportTraceLogInteractor {
  final TraceLogRepository _traceLogRepository;

  ExportTraceLogInteractor(this._traceLogRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(ExportTraceLogLoading());
      final savePath = await _traceLogRepository.exportTraceLog();
      yield Right<Failure, Success>(ExportTraceLogSuccess(savePath));
    } catch (exception) {
      yield Left<Failure, Success>(ExportTraceLogFailure(exception));
    }
  }
}