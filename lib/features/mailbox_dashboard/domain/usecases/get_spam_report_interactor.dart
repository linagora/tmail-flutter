import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';

import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_last_time_dismissed_spam_reported_state.dart';

class GetSpamReportInteractor {
  final SpamReportRepository _spamReportRepository;

  GetSpamReportInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetLastTimeDismissedSpamReportedLoading());
      final _lastTimeDismissedSpamReported = await _spamReportRepository.getLastTimeDismissedSpamReported();
      yield Right<Failure, Success>(GetLastTimeDismissedSpamReportedSuccess(_lastTimeDismissedSpamReported));
    } catch (e) {
      yield Left<Failure, Success>(GetLastTimeDismissedSpamReportedFailure(e));
    }
  }
}