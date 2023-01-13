
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_number_of_unread_spam_emails_state.dart';

class GetUnreadSpamMailboxInteractor {
  static const int conditionsForDisplayingSpamReportBanner = 4;
  final SpamReportRepository _spamReportRepository;

  GetUnreadSpamMailboxInteractor(this._spamReportRepository);

   Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    {
      UnsignedInt? limit,
      MailboxFilterCondition? mailboxFilterCondition,
    }
  ) async* {
    try {
      yield Right(GetUnreadSpamMailboxLoading());
      final _lastTimeDissmissedSpamReported = await _spamReportRepository.getLastTimeDismissedSpamReported();
      final _timeLast = DateTime.now().difference(_lastTimeDissmissedSpamReported);

      final _checkTimeCondition = (_timeLast.inHours > 0) && (_timeLast.inHours > conditionsForDisplayingSpamReportBanner);

      if (_checkTimeCondition) {
        final _response =  await _spamReportRepository.getUnreadSpamMailbox(accountId, mailboxFilterCondition: mailboxFilterCondition, limit: limit);
        final _unreadSpamMailbox = _response.unreadSpamMailbox;

        yield Right(GetUnreadSpamMailboxSuccess(_unreadSpamMailbox!));
      } else {
        yield Left(InvalidSpamReportCondition());
      }
    } catch (e) {
      yield Left(GetUnreadSpamMailboxFailure(e));
    }
  }
}