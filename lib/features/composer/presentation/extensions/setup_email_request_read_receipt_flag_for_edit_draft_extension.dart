
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SetupEmailRequestReadReceiptFlagExtension on ComposerController {

  void setupEmailRequestReadReceiptFlagForEditDraft(bool isRequestReadReceipt) {
    hasRequestReadReceipt.value = isRequestReadReceipt;
  }
}