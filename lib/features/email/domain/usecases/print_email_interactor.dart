import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
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
      final htmlContentTransformed = await _transformHtmlEmailContent(emailPrint.emailContent);
      final newEmailPrint = emailPrint.fromEmailContent(htmlContentTransformed);
      await emailRepository.printEmail(newEmailPrint);
      yield Right(PrintEmailSuccess());
    } catch (e) {
      yield Left(PrintEmailFailure(exception: e));
    }
  }

  Future<String> _transformHtmlEmailContent(String emailContent) async {
    try {
      final htmlContentTransformed = await emailRepository.transformHtmlEmailContent(
        emailContent,
        TransformConfiguration.forPrintEmail());
      log('PrintEmailInteractor::_transformHtmlEmailContent: htmlContentTransformed: $htmlContentTransformed');
      return htmlContentTransformed;
    } catch (e) {
      logError('PrintEmailInteractor::_transformHtmlEmailContent: Exception: $e');
      return emailContent;
    }
  }
}