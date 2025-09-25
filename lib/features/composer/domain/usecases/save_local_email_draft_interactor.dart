import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_local_email_draft_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';

class SaveLocalEmailDraftInteractor {
  final LocalEmailDraftRepository _localEmailDraftRepository;
  final ComposerRepository _composerRepository;

  SaveLocalEmailDraftInteractor(
    this._localEmailDraftRepository,
    this._composerRepository,
  );

  Future<Either<Failure, Success>> execute(
    CreateEmailRequest createEmailRequest,
    AccountId accountId,
    UserName userName,
  ) async {
    try {
      final emailCreated = await _composerRepository.generateEmail(
        createEmailRequest,
        withIdentityHeader: true,
        isDraft: true,
      );
      await _localEmailDraftRepository.saveLocalEmailDraft(
        createEmailRequest.generateLocalEmailDraftFromEmail(
          email: emailCreated,
          accountId: accountId,
          userName: userName,
        ),
      );
      return Right(SaveLocalEmailDraftSuccess());
    } catch (exception) {
      return Left(SaveLocalEmailDraftFailure(exception));
    }
  }
}
