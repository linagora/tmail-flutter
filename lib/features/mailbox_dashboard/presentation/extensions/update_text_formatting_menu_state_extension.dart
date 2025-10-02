import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_text_formatting_menu_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_text_formatting_menu_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension UpdateTextFormattingMenuStateExtension on MailboxDashBoardController {
  void initialTextFormattingMenuState() {
    getTextFormattingMenuStateInteractor =
        getBinding<GetTextFormattingMenuStateInteractor>();
    if (getTextFormattingMenuStateInteractor == null) return;

    consumeState(getTextFormattingMenuStateInteractor!.execute());
  }

  void updateTextFormattingMenuState(bool isDisplayed) {
    isTextFormattingMenuOpened.value = isDisplayed;
    log('$runtimeType::updateTextFormattingMenuState(): isDisplayed: $isDisplayed');
  }

  void saveTextFormattingMenuState() {
    saveTextFormattingMenuStateInteractor =
        getBinding<SaveTextFormattingMenuStateInteractor>();
    if (saveTextFormattingMenuStateInteractor == null) return;

    final isDisplayed = isTextFormattingMenuOpened.value;
    consumeState(
      saveTextFormattingMenuStateInteractor!.execute(isDisplayed),
    );
  }
}
