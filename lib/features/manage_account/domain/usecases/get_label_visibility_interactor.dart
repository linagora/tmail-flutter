import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_visibility_state.dart';

class GetLabelVisibilityInteractor {
  final ManageAccountRepository _manageAccountRepository;

  GetLabelVisibilityInteractor(this._manageAccountRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingLabelVisibility());
      final visible = await _manageAccountRepository.getLabelVisibility();
      yield Right(GetLabelVisibilitySuccess(visible));
    } catch (exception) {
      yield Left(GetLabelVisibilityFailure(exception));
    }
  }
}
