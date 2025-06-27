import 'package:core/core.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/aibot/domain/repository/aibot_repository.dart';
import 'package:tmail_ui_user/features/aibot/domain/state/suggest_reply_state.dart';

class AiBotSuggestReply {
  final AibotRepository _repository;

  AiBotSuggestReply(this._repository);

  Stream<dartz.Either<Failure, Success>> execute({
    required AccountId accountId,
    required String userInput,
    String? mailId,
  }) async* {
    yield dartz.Right(SuggestReplyLoading());

    final suggestion = await _repository.suggestReply(
      accountId: accountId,
      userInput: userInput,
      emailId: mailId ?? '',
    );

    yield suggestion.fold(
      (failure) => dartz.Left(SuggestReplyFailure(failure.toString())),
      (suggestion) => dartz.Right(SuggestReplySuccess(suggestion)),
    );
  }
}
