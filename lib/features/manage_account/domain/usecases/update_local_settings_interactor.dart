import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_local_settings_state.dart';

class UpdateLocalSettingsInteractor {
  const UpdateLocalSettingsInteractor(this._manageAccountRepository);

  final ManageAccountRepository _manageAccountRepository;

  Stream<Either<Failure, Success>> execute(PreferencesConfig preferencesConfig) async* {
    try {
      yield Right(UpdatingLocalSettingsState());
      final preferencesSetting = await _manageAccountRepository.toggleLocalSettingsState(
        preferencesConfig,
      );
      yield Right(UpdateLocalSettingsSuccess(preferencesSetting));
    } catch (e) {
      yield Left(UpdateLocalSettingsFailure(exception: e));
    }
  }
}