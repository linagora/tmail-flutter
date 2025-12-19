import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_ai_scribe_config_state.dart';

class GetAIScribeConfigInteractor {
  const GetAIScribeConfigInteractor(this._manageAccountRepository);

  final ManageAccountRepository _manageAccountRepository;

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingAIScribeConfigState());
      final aiScribeConfig =
          await _manageAccountRepository.getAiScribeConfigLocalSettings();
      yield Right(GetAIScribeConfigSuccess(aiScribeConfig));
    } catch (e) {
      yield Left(GetAIScribeConfigFailure(exception: e));
    }
  }
}
