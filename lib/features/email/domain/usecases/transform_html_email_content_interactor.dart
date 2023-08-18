
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/transform_html_email_content_state.dart';

class TransformHtmlEmailContentInteractor {
  final EmailRepository emailRepository;

  TransformHtmlEmailContentInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(
    String htmlContent,
    TransformConfiguration configuration
  ) async* {
    try {
      yield Right<Failure, Success>(TransformHtmlEmailContentLoading());
      final htmlContentTransformed = await emailRepository.transformHtmlEmailContent(htmlContent, configuration);
      yield Right<Failure, Success>(TransformHtmlEmailContentSuccess(htmlContentTransformed));
    } catch (e) {
      yield Left<Failure, Success>(TransformHtmlEmailContentFailure(e));
    }
  }
}