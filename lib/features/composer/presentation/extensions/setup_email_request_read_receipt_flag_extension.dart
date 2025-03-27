
import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:model/email/email_action_type.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';

extension SetupEmailRequestReadReceiptFlagExtension on ComposerController {

  Future<void> setupEmailRequestReadReceiptFlag(ComposerArguments arguments) async {
    if (currentEmailActionType == EmailActionType.reopenComposerBrowser) {
      hasRequestReadReceipt.value = arguments.hasRequestReadReceipt ?? false;
    } else if (currentEmailActionType != EmailActionType.editDraft) {
      await getServerSetting();
    }
  }

  Future<void> getServerSetting() async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId == null) return;

    final resultState = await getServerSettingInteractor.execute(accountId).last;

    resultState.foldSuccess<GetServerSettingSuccess>(
      onFailure: (_) {},
      onSuccess: (success) {
        hasRequestReadReceipt.value = success.settingOption.isAlwaysReadReceipts;
      },
    );
  }
}