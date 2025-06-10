import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class GetLocalSettingsInteractor {
  const GetLocalSettingsInteractor(this._manageAccountRepository);

  final ManageAccountRepository _manageAccountRepository;

  Stream<Either<Failure, Success>> execute(
    List<SupportedLocalSetting> supportedLocalSettings,
  ) async* {
    try {
      yield Right(GettingLocalSettingsState());
      final result = await _manageAccountRepository.getLocalSettings(supportedLocalSettings);
      yield Right(GetLocalSettingsSuccess(result));
    } catch (e) {
      logError('$runtimeType::execute(): exception: $e');
      yield Left(GetLocalSettingsFailure(exception: e));
    }
  }
}