import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_label_visibility_state.dart';

class SaveLabelVisibilityInteractor {
  final ManageAccountRepository _manageAccountRepository;

  SaveLabelVisibilityInteractor(this._manageAccountRepository);

  Stream<Either<Failure, Success>> execute({bool visible = true}) async* {
    try {
      yield Right(SavingLabelVisibility());
      await _manageAccountRepository.saveLabelVisibility(visible);
      yield Right(SaveLabelVisibilitySuccess());
    } catch (exception) {
      yield Left(SaveLabelVisibilityFailure(exception));
    }
  }
}
