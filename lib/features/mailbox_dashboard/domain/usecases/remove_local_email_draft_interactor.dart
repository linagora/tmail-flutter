import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_local_email_draft_state.dart';

class RemoveLocalEmailDraftInteractor {
  final LocalEmailDraftRepository _localEmailDraftRepository;

  RemoveLocalEmailDraftInteractor(this._localEmailDraftRepository);

  Future<Either<Failure, Success>> execute(String draftLocalId) async {
    try {
      _localEmailDraftRepository.removeLocalEmailDraft(draftLocalId);
      return Right(RemoveLocalEmailDraftSuccess());
    } catch (exception) {
      return Left(RemoveLocalEmailDraftFailure(exception));
    }
  }
}
