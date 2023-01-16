import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/delete_spam_report_state.dart';

class DeleteSpamReportStateInteractor {
  final SpamReportRepository _spamReportRepository;

  DeleteSpamReportStateInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DeleteSpamReportStateLoading());
        await _spamReportRepository.deleteSpamReportState();
      yield Right<Failure, Success>(DeleteSpamReportStateSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DeleteSpamReportStateFailure(e));
    }
  }
}