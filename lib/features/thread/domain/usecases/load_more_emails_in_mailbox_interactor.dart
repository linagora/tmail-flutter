import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';

class LoadMoreEmailsInMailboxInteractor {
  final ThreadRepository threadRepository;

  LoadMoreEmailsInMailboxInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(GetEmailRequest emailRequest) async* {
    try {
      yield Right<Failure, Success>(LoadingMoreState());

      yield* threadRepository.loadMoreEmails(emailRequest).map(_toGetEmailState);
    } catch (e) {
      yield Left(LoadMoreEmailsFailure(e));
    }
  }

  Either<Failure, Success> _toGetEmailState(EmailsResponse emailResponse) {
    final presentationEmailList = emailResponse.emailList
      ?.map((email) => email.toPresentationEmail()).toList() ?? List.empty();

    return Right<Failure, Success>(LoadMoreEmailsSuccess(presentationEmailList));
  }
}