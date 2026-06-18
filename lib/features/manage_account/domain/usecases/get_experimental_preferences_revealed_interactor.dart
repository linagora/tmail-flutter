import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';

class GetExperimentalPreferencesRevealedInteractor {
  const GetExperimentalPreferencesRevealedInteractor(this._repository);

  final ManageAccountRepository _repository;

  Future<bool> execute() => _repository.getExperimentalPreferencesRevealed();
}
