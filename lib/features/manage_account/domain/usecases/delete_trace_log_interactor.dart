import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/trace_log_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_trace_log_state.dart';

class DeleteTraceLogInteractor {
  final TraceLogRepository _traceLogRepository;

  DeleteTraceLogInteractor(this._traceLogRepository);

  Stream<Either<Failure, Success>> execute(String path) async* {
    try {
      yield Right<Failure, Success>(DeleteTraceLogLoading());
      await _traceLogRepository.deleteTraceLog(path);
      yield Right<Failure, Success>(DeleteTraceLogSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(DeleteTraceLogFailure(exception));
    }
  }
}