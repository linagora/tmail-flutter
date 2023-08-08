
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_number_of_unread_spam_emails_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_spam_mailbox_cached_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/utils/mailbox_dashboard_constant.dart';

class GetSpamMailboxCachedInteractor {
  final SpamReportRepository _spamReportRepository;

  GetSpamMailboxCachedInteractor(this._spamReportRepository);

   Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      yield Right<Failure, Success>(GetSpamMailboxCachedLoading());

      final lastTimeDismissedSpamReported = await _spamReportRepository.getLastTimeDismissedSpamReported();
      final timeLast = DateTime.now().difference(lastTimeDismissedSpamReported);
      final checkTimeCondition = timeLast.inHours > MailboxDashboardConstant.spamReportBannerDisplayTimeOut;

      if (checkTimeCondition) {
        final spamMailbox =  await _spamReportRepository.getSpamMailboxCached(accountId, userName);
        final countUnreadSpamMailbox = spamMailbox.unreadEmails?.value.value.toInt() ?? 0;
        if (countUnreadSpamMailbox > 0) {
          yield Right<Failure, Success>(GetSpamMailboxCachedSuccess(spamMailbox));
        } else {
          yield Left<Failure, Success>(InvalidSpamReportCondition());
        }
      } else {
        yield Left<Failure, Success>(InvalidSpamReportCondition());
      }
    } catch (e) {
      yield Left<Failure, Success>(GetSpamMailboxCachedFailure(e));
    }
  }
}