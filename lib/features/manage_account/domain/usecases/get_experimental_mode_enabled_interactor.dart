import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/experimental_mode_state.dart';

class GetExperimentalModeEnabledInteractor {
  const GetExperimentalModeEnabledInteractor(this._repository);

  final ManageAccountRepository _repository;

  Future<Either<Failure, Success>> execute() async {
    try {
      final isEnabled = await _repository.getExperimentalModeEnabled();
      return Right(GetExperimentalModeEnabledSuccess(isEnabled));
    } catch (e) {
      return Left(GetExperimentalModeEnabledFailure(e));
    }
  }
}
