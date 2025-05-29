import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class UpdateLocalSettingsInteractor {
  const UpdateLocalSettingsInteractor(this._manageAccountRepository);

  final ManageAccountRepository _manageAccountRepository;

  Stream<Either<Failure, Success>> execute(
    LocalSettingOptions localSettingOptions,
  ) async* {
    try {
      yield Right(UpdatingLocalSettingsState());
      await _manageAccountRepository.updateLocalSettings(localSettingOptions);
      yield Right(UpdateLocalSettingsSuccess(localSettingOptions));
    } catch (e) {
      logError('$runtimeType::execute(): exception: $e');
      yield Left(UpdateLocalSettingsFailure(exception: e));
    }
  }
}