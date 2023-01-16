
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_spam_report_state.dart';

class StoreSpamReportStateInteractor {
  final SpamReportRepository _spamReportRepository;

  StoreSpamReportStateInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute(SpamReportState spamReportState) async* {
    try {
      yield Right<Failure, Success>(StoreSpamReportStateLoading());
      await _spamReportRepository.storeSpamReportState(spamReportState);
      yield Right<Failure, Success>(StoreSpamReportStateSuccess(spamReportState));
    } catch (e) {
      yield Left<Failure, Success>(StoreSpamReportStateFailure(e));
    }
  }
}