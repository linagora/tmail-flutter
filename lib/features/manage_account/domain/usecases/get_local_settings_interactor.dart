import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';

class GetLocalSettingsInteractor {
  const GetLocalSettingsInteractor(this._manageAccountRepository);

  final ManageAccountRepository _manageAccountRepository;

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingLocalSettingsState());
      final result = await _manageAccountRepository.getLocalSettings();
      yield Right(GetLocalSettingsSuccess(result));
    } catch (e) {
      logError('$runtimeType::execute(): exception: $e');
      yield Left(GetLocalSettingsFailure(exception: e));
    }
  }
}