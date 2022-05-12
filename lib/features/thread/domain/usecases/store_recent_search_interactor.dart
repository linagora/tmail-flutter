import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/recent_search_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/store_recent_search_state.dart';


class StoreRecentSearchInteractor {

  final RecentSearchRepository storeRecentSearchInteractor;

  StoreRecentSearchInteractor(this.storeRecentSearchInteractor);

  Stream<Either<Failure, Success>> execute(String keyword) async* {
    try {
       final result = await storeRecentSearchInteractor.storeKeyword(keyword);
       yield Right<Failure, Success>(StoreRecentSearchSuccess(result));
    } catch (e) {
      yield Left<Failure, Success>(StoreRecentSearchSuccessFailure(e));
    }
  }
}