import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/print_email_state.dart';

class PrintEmailInteractor {
  final EmailRepository emailRepository;

  PrintEmailInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(EmailPrint emailPrint) async* {
    try {
      yield Right(PrintEmailLoading());
      await emailRepository.printEmail(emailPrint);
      yield Right(PrintEmailSuccess());
    } catch (e) {
      yield Left(PrintEmailFailure(exception: e));
    }
  }
}