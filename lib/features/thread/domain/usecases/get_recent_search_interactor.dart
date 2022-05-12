import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/recent_search_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_recent_search_state.dart';


class GetRecentSearchInteractor {
  final RecentSearchRepository recentSearchRepository;

  GetRecentSearchInteractor(this.recentSearchRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      final result = await recentSearchRepository.getAll();
      if (result.isNotEmpty) {
        yield Right<Failure, Success>(GetRecentSearchSuccess(result));
      } else {
        yield Left<Failure, Success>(GetRecentSearchFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(GetRecentSearchFailure(e));
    }
  }
}