import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_emoji_mart/flutter_emoji_mart.dart';
import 'package:tmail_ui_user/features/reactions/domain/repository/reactions_repository.dart';
import 'package:tmail_ui_user/features/reactions/domain/state/get_recent_reactions_state.dart';

class GetRecentReactionsInteractor {
  final ReactionsRepository _repository;

  GetRecentReactionsInteractor(this._repository);

  Future<Either<Failure, Success>> execute() async {
    try {
      final reactions = await _repository.getRecentReactions();

      return Right<Failure, Success>(GetRecentReactionsSuccess(
        Category(
          id: EmojiPickerConfiguration.recentCategoryId,
          emojiIds: reactions,
        ),
      ));
    } catch (exception) {
      return Left<Failure, Success>(GetRecentReactionsFailure(exception));
    }
  }
}
