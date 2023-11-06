
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_number_of_unread_spam_emails_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_mailbox_cached_interactor.dart';

class GetUnreadSpamMailboxInteractor {
  final SpamReportRepository _spamReportRepository;

  GetUnreadSpamMailboxInteractor(this._spamReportRepository);

   Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      MailboxFilterCondition? mailboxFilterCondition,
    }
  ) async* {
    try {
      yield Right(GetUnreadSpamMailboxLoading());
      if (await _validateIntervalToShowBanner()) {
        final response =  await _spamReportRepository.getUnreadSpamMailbox(
          session,
          accountId,
          mailboxFilterCondition: mailboxFilterCondition,
          limit: limit);
        final unreadSpamMailbox = response.unreadSpamMailbox;

        if (unreadSpamMailbox!.unreadEmails!.value.value > 0) {
          yield Right(GetUnreadSpamMailboxSuccess(unreadSpamMailbox));
        } else {
          yield Left(InvalidSpamReportCondition());
        }
      } else {
        yield Left(InvalidSpamReportCondition());
      }
    } catch (e) {
      yield Left(GetUnreadSpamMailboxFailure(e));
    }
  }

  Future<bool> _validateIntervalToShowBanner() async {
    final lastTimeDismissedSpamReported = await _spamReportRepository.getLastTimeDismissedSpamReported();
    final currentTime = DateTime.now().difference(lastTimeDismissedSpamReported);
    log('GetUnreadSpamMailboxInteractor::_compareSpamReportTime:lastTimeDismissedSpamReported: $lastTimeDismissedSpamReported | currentTime: $currentTime');
    return currentTime.inHours > GetSpamMailboxCachedInteractor.spamReportBannerDisplayIntervalInHour;
  }
}