import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/local_email_draft_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';

class GetAllLocalEmailDraftInteractor {
  final LocalEmailDraftRepository _localEmailDraftRepository;

  GetAllLocalEmailDraftInteractor(this._localEmailDraftRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      final listLocalEmailDraft = await _localEmailDraftRepository.getLocalEmailDraft(
        accountId,
        userName,
      );
      yield Right(GetLocalEmailDraftSuccess(listLocalEmailDraft));
    } catch (exception) {
      yield Left(GetLocalEmailDraftFailure(exception));
    }
  }
}