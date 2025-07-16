import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_detail_status_state.dart';

class GetThreadDetailStatusInteractor {
  const GetThreadDetailStatusInteractor(this._threadDetailRepository);

  final ThreadDetailRepository _threadDetailRepository;

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingThreadDetailStatus());
      final result = await _threadDetailRepository.getThreadDetailStatus();
      yield Right(GetThreadDetailStatusSuccess(result));
    } catch (e) {
      logError('GetThreadDetailStatusInteractor::execute(): Exception: $e');
      yield Left(GetThreadDetailStatusFailure(exception: e));
    }
  }
}