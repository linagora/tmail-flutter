

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_spam_report_state.dart';

class StoreSpamReportStateInteractor {
  final SpamReportRepository _spamReportRepository;

  StoreSpamReportStateInteractor(this._spamReportRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetSpamReportStateLoading());
      final spamReportState = await _spamReportRepository.getSpamReportState();
      yield Right<Failure, Success>(GetSpamReportStateSuccess(spamReportState));
    } catch (e) {
      yield Left<Failure, Success>(GetSpamReportStateFailure(e));
    }
  }
}