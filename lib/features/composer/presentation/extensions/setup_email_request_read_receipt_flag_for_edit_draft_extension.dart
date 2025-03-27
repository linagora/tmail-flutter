
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_request_read_receipt_flag_extension.dart';

extension SetupEmailRequestReadReceiptFlagExtension on ComposerController {

  Future<void> setupEmailRequestReadReceiptFlagForEditDraft(bool? isRequestReadReceipt) async {
    if (isRequestReadReceipt == true) {
      hasRequestReadReceipt.value = true;
    } else {
      await getServerSetting();
    }
  }
}