import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/store_last_time_dismissed_spam_report_state.dart';

class StoreLastTimeDismissedSpamReportInteractor {
  final ThreadRepository _threadRepository;

  StoreLastTimeDismissedSpamReportInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(DateTime lastTimeDismissedSpamReport) async* {
    try {
      yield Right<Failure, Success>(StoreLastTimeDismissedSpamReportLoading());
      await _threadRepository.storelastTimeDismissedSpamReport(lastTimeDismissedSpamReport);
      yield Right<Failure, Success>(StoreLastTimeDismissedSpamReportSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreLastTimeDismissedSpamReportFailure(e));
    }
  }
}