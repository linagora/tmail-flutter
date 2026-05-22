import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/experimental_mode_state.dart';

class EnableExperimentalModeInteractor {
  const EnableExperimentalModeInteractor(this._repository);

  final ManageAccountRepository _repository;

  Future<Either<Failure, Success>> execute() async {
    try {
      await _repository.enableExperimentalMode();
      return Right(EnableExperimentalModeSuccess());
    } catch (e) {
      return Left(EnableExperimentalModeFailure(e));
    }
  }
}
