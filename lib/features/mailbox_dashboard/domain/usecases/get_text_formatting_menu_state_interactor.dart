import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_text_formatting_menu_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';

class GetTextFormattingMenuStateInteractor {
  final ManageAccountRepository _manageAccountRepository;

  GetTextFormattingMenuStateInteractor(this._manageAccountRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingTextFormattingMenuState());
      final preferencesSetting =
          await _manageAccountRepository.getLocalSettings();
      yield Right(GetTextFormattingMenuStateSuccess(
        preferencesSetting.textFormattingMenuConfig.isDisplayed,
      ));
    } catch (exception) {
      yield Left(GetTextFormattingMenuStateFailure(exception));
    }
  }
}
