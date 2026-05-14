import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/save_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/update_template_email_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
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
    final templateEmailId = createEmailRequest.templateEmailId;
    final isCreatingNewTemplate = templateEmailId == null;
    try {
      yield Right(GenerateEmailLoading());

      final emailCreated = await _createEmailObject(createEmailRequest);
      if (emailCreated == null) {
        yield Left(GenerateEmailFailure(CannotCreateEmailObjectException()));
        return;
      }

      final payload = (
        session: createEmailRequest.session,
        accountId: createEmailRequest.accountId,
        email: emailCreated,
      );

      if (!isCreatingNewTemplate) {
        yield* _updateTemplateEmail(
          payload: payload,
          templateEmailId: templateEmailId,
          cancelToken: cancelToken,
        );
      } else {
        yield* _saveEmailAsTemplate(
          payload: payload,
          createNewMailboxRequest: createNewMailboxRequest,
          cancelToken: cancelToken,
        );
      }
    } catch (e) {
      logWarning('SaveTemplateEmailInteractor::execute(): $e');
      yield _buildFailure(exception: e, isCreatingNewTemplate: isCreatingNewTemplate);
    }
  }

  Stream<Either<Failure, Success>> _saveEmailAsTemplate({
    required ({Session session, AccountId accountId, Email email}) payload,
    required CreateNewMailboxRequest? createNewMailboxRequest,
    CancelToken? cancelToken,
  }) async* {
    try {
      yield Right(SavingTemplateEmail());

      final emailSaved = await _emailRepository.saveEmailAsTemplate(
        payload.session,
        payload.accountId,
        payload.email,
        createNewMailboxRequest: createNewMailboxRequest,
        cancelToken: cancelToken,
      );

      final newEmailId = emailSaved.id;
      if (newEmailId == null) {
        yield Left(SaveTemplateEmailFailure(exception: NotFoundEmailIdException()));
      } else {
        yield Right(SaveTemplateEmailSuccess(newEmailId));
      }
    } catch (e) {
      logWarning('SaveTemplateEmailInteractor::_saveEmailAsTemplate(): $e');
      yield _buildFailure(exception: e, isCreatingNewTemplate: true);
    }
  }

  Stream<Either<Failure, Success>> _updateTemplateEmail({
    required ({Session session, AccountId accountId, Email email}) payload,
    required EmailId templateEmailId,
    CancelToken? cancelToken,
  }) async* {
    try {
      yield Right(UpdatingTemplateEmail());

      final emailSaved = await _emailRepository.updateEmailTemplate(
        payload.session,
        payload.accountId,
        payload.email,
        templateEmailId,
        cancelToken: cancelToken,
      );

      final updatedEmailId = emailSaved.id;
      if (updatedEmailId == null) {
        yield Left(UpdateTemplateEmailFailure(exception: NotFoundEmailIdException()));
      } else {
        yield Right(UpdateTemplateEmailSuccess(
          emailId: updatedEmailId,
          attachments: emailSaved.allAttachments,
          htmlBodyAttachments: emailSaved.htmlBodyAttachments,
        ));
      }
    } catch (e) {
      logWarning('SaveTemplateEmailInteractor::_updateTemplateEmail(): $e');
      yield _buildFailure(exception: e, isCreatingNewTemplate: false);
    }
  }

  Either<Failure, Success> _buildFailure({
    required Object? exception,
    required bool isCreatingNewTemplate,
  }) => Left(
    !isCreatingNewTemplate
      ? UpdateTemplateEmailFailure(exception: exception)
      : SaveTemplateEmailFailure(exception: exception),
  );

  Future<Email?> _createEmailObject(CreateEmailRequest createEmailRequest) async {
    try {
      return await _composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true,
        isTemplate: true,
      );
    } catch (e) {
      logWarning('SaveTemplateEmailInteractor::_createEmailObject(): $e');
      return null;
    }
  }
}
