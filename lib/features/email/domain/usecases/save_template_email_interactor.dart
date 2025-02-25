import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/save_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/update_template_email_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';

class SaveTemplateEmailInteractor {
  const SaveTemplateEmailInteractor(
    this._composerRepository,
    this._emailRepository,
  );

  final ComposerRepository _composerRepository;
  final EmailRepository _emailRepository;

  Stream<Either<Failure, Success>> execute({
    required CreateEmailRequest createEmailRequest,
    required CreateNewMailboxRequest? createNewMailboxRequest,
    CancelToken? cancelToken,
  }) async* {
    yield Right(GenerateEmailLoading());

    try {
      final emailCreated = await _createEmailObject(createEmailRequest);

      if (emailCreated == null) {
        yield Left(GenerateEmailFailure(CannotCreateEmailObjectException()));
        return;
      }

      if (createEmailRequest.templateEmailId != null) {
        yield Right(UpdatingTemplateEmail());
        final emailTemplateSaved = await _emailRepository.updateEmailTemplate(
          createEmailRequest.session,
          createEmailRequest.accountId,
          emailCreated,
          createEmailRequest.templateEmailId!,
          cancelToken: cancelToken,
        );
        yield Right(UpdateTemplateEmailSuccess(emailTemplateSaved.id!));
      } else {
        yield Right(SavingTemplateEmail());
        final emailTemplateSaved = await _emailRepository.saveEmailAsTemplate(
          createEmailRequest.session,
          createEmailRequest.accountId,
          emailCreated,
          createNewMailboxRequest: createNewMailboxRequest,
          cancelToken: cancelToken,
        );
        yield Right(SaveTemplateEmailSuccess(emailTemplateSaved.id!));
      }
    } catch (e) {
      logError('SaveTemplateEmailInteractor::execute(): $e');
      if (createEmailRequest.templateEmailId != null) {
        yield Left(UpdateTemplateEmailFailure(exception: e));
      } else {
        yield Left(SaveTemplateEmailFailure(exception: e));
      }
    }
  }

  Future<Email?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true,
        isTemplate: true);
      return emailCreated;
    } catch (e) {
      logError('CreateNewAndSaveEmailToDraftsInteractor::_createEmailObject: Exception: $e');
      return null;
    }
  }
}