import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/delete_last_time_dismissed_spam_reported_state.dart';

class DeleteLastTimeDismissedSpamReportedInteractor {
  final SpamReportRepository _spamReportRepository;

  DeleteLastTimeDismissedSpamReportedInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DeleteLastTimeDismissedSpamReportedLoading());
        await _spamReportRepository.deleteLastTimeDismissedSpamReported();
      yield Right<Failure, Success>(DeleteLastTimeDismissedSpamReportedSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DeleteLastTimeDismissedSpamReportedFailure(e));
    }
  }
}