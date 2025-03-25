import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_all_local_email_draft_state.dart';

class RemoveAllLocalEmailDraftsInteractor {
  final LocalEmailDraftRepository _localEmailDraftRepository;

  RemoveAllLocalEmailDraftsInteractor(this._localEmailDraftRepository);

  Future<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async {
    try {
      await _localEmailDraftRepository.removeAllLocalEmailDrafts(accountId, userName);
      return Right(RemoveAllLocalEmailDraftsSuccess());
    } catch (exception) {
      return Left(RemoveAllLocalEmailDraftsFailure(exception));
    }
  }
}
