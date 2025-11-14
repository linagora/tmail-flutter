import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/reactions/domain/extensions/list_reactions_extesion.dart';
import 'package:tmail_ui_user/features/reactions/domain/repository/reactions_repository.dart';
import 'package:tmail_ui_user/features/reactions/domain/state/store_recent_reactions_state.dart';

class StoreRecentReactionsInteractor {
  final ReactionsRepository _repository;

  StoreRecentReactionsInteractor(this._repository);

  Stream<Either<Failure, Success>> execute({required String emojiId}) async* {
    try {
      yield Right<Failure, Success>(StoreRecentReactionsLoading());

      final reactions = await _repository.getRecentReactions();

      final updatedReactions =
          List<String>.from(reactions).combineRecentReactions(emojiId);

      await _repository.storeRecentReactions(updatedReactions);

      yield Right<Failure, Success>(StoreRecentReactionsSuccess());
    } catch (exception) {
      yield Left<Failure, Success>(StoreRecentReactionsFailure(exception));
    }
  }
}
