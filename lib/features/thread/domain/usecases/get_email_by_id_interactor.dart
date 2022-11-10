import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';

class GetEmailByIdInteractor {
  final ThreadRepository _threadRepository;

  GetEmailByIdInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    EmailId emailId,
    {
      MailboxId? mailboxId,
      DashboardType dashboardType = DashboardType.normal,
      Properties? properties,
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailByIdLoading());
      final email = await _threadRepository.getEmailById(accountId, emailId, properties: properties);
      yield Right<Failure, Success>(GetEmailByIdSuccess(email, mailboxId, dashboardType));
    } catch (e) {
      yield Left<Failure, Success>(GetEmailByIdFailure(e));
    }
  }
}