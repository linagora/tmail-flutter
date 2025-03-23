import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_composer_cache_state.dart';

class RemoveLocalEmailDraftInteractor {
  final LocalEmailDraftRepository _localEmailDraftRepository;

  RemoveLocalEmailDraftInteractor(this._localEmailDraftRepository);

  Future<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) async {
    try {
      _localEmailDraftRepository.removeLocalEmailDraft(
        accountId,
        userName,
        composerId,
      );
      return Right(RemoveLocalEmailDraftSuccess());
    } catch (exception) {
      return Left(RemoveLocalEmailDraftFailure(exception));
    }
  }
}
