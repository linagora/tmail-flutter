import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_state.dart';

class SaveComposerCacheOnWebInteractor {
  final ComposerCacheRepository _composerCacheRepository;
  final ComposerRepository _composerRepository;

  SaveComposerCacheOnWebInteractor(
    this._composerCacheRepository,
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
      await _composerCacheRepository.saveComposerCacheOnWeb(
        accountId: accountId,
        userName: userName,
        composerCache: ComposerCache(
          email: emailCreated,
          hasRequestReadReceipt: createEmailRequest.hasRequestReadReceipt,
          isMarkAsImportant: createEmailRequest.isMarkAsImportant,
          displayMode: createEmailRequest.displayMode,
          composerIndex: createEmailRequest.composerIndex,
          composerId: createEmailRequest.composerId,
          draftHash: createEmailRequest.savedDraftHash,
          actionType: createEmailRequest.savedActionType,
          draftEmailId: createEmailRequest.draftsEmailId,
        ));
      return Right(SaveComposerCacheSuccess());
    } catch (exception) {
      return Left(SaveComposerCacheFailure(exception));
    }
  }
}
