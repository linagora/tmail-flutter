import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_text_formatting_menu_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';

class SaveTextFormattingMenuStateInteractor {
  final ManageAccountRepository _manageAccountRepository;

  SaveTextFormattingMenuStateInteractor(this._manageAccountRepository);

  Stream<Either<Failure, Success>> execute(bool isDisplayed) async* {
    try {
      yield Right(SavingTextFormattingMenuState());
      final preferencesSetting = await _manageAccountRepository.toggleLocalSettingsState(
        TextFormattingMenuConfig(isDisplayed: isDisplayed),
      );
      yield Right(SaveTextFormattingMenuStateSuccess(
        preferencesSetting.textFormattingMenuConfig.isDisplayed,
      ));
    } catch (exception) {
      yield Left(SaveTextFormattingMenuStateFailure(exception));
    }
  }
}
