import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_spam_report_state.dart';

class StoreSpamReportInteractor {
  final SpamReportRepository _spamReportRepository;

  StoreSpamReportInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute(DateTime lastTimeDismissedSpamReported) async* {
    try {
      yield Right<Failure, Success>(StoreSpamReportLoading());
      await _spamReportRepository.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
      yield Right<Failure, Success>(StoreSpamReportSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreSpamReportFailure(e));
    }
  }
}