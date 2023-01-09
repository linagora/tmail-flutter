import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_last_time_dismissed_spam_reported_state.dart';

class StoreSpamReportInteractor {
  final StoreLastTimeDismissedSpamReportInteractor _spamReportRepository;

  StoreSpamReportInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute(DateTime lastTimeDismissedSpamReported) async* {
    try {
      yield Right<Failure, Success>(StoreLastTimeDismissedSpamReportLoading());
      await _spamReportRepository.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
      yield Right<Failure, Success>(StoreLastTimeDismissedSpamReportSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreLastTimeDismissedSpamReportFailure(e));
    }
  }
}