import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_local_email_draft_state.dart';

class GetAllLocalEmailDraftInteractor {
  final LocalEmailDraftRepository _localEmailDraftRepository;

  GetAllLocalEmailDraftInteractor(this._localEmailDraftRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      yield Right(GetAllLocalEmailDraftLoading());
      final listLocalEmailDraft = await _localEmailDraftRepository
        .getAllLocalEmailDraft(accountId, userName);
      yield Right(GetAllLocalEmailDraftSuccess(listLocalEmailDraft));
    } catch (exception) {
      yield Left(GetAllLocalEmailDraftFailure(exception));
    }
  }
}