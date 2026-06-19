import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';

class RevealExperimentalPreferencesInteractor {
  const RevealExperimentalPreferencesInteractor(this._manageAccountRepository);

  final ManageAccountRepository _manageAccountRepository;

  Future<void> execute() => _manageAccountRepository.saveExperimentalPreferencesRevealed();
}
