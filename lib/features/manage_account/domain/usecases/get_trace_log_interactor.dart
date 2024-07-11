import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/trace_log_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_trace_log_state.dart';

class GetTraceLogInteractor {
  final TraceLogRepository _traceLogRepository;

  GetTraceLogInteractor(this._traceLogRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetTraceLogLoading());
      final response = await _traceLogRepository.getTraceLog();
      yield Right<Failure, Success>(GetTraceLogSuccess(response));
    } catch (exception) {
      yield Left<Failure, Success>(GetTraceLogFailure(exception));
    }
  }
}