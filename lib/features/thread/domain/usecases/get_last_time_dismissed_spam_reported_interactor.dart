import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_last_time_dismissed_spam_reported_state.dart';

class GetLastTimeDismissedSpamReportInteractor {
  final ThreadRepository _threadRepository;

  GetLastTimeDismissedSpamReportInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(
      DateTime lastTimeDismissedSpamReport) async* {
    try {
      yield Right<Failure, Success>(GetLastTimeDismissedSpamReportLoading());
      final lastTimeDismissedSpamReport = await _threadRepository.getlastTimeDismissedSpamReport();
      yield Right<Failure, Success>(
          GetLastTimeDismissedSpamReportSuccess(lastTimeDismissedSpamReport));
    } catch (e) {
      yield Left<Failure, Success>(GetLastTimeDismissedSpamReportFailure(e));
    }
  }
}