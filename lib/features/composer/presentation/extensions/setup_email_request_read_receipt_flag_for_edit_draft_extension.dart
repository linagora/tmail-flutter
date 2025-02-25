
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SetupEmailRequestReadReceiptFlagExtension on ComposerController {

  void setupEmailRequestReadReceiptFlag(bool isRequestReadReceipt) {
    hasRequestReadReceipt.value = isRequestReadReceipt;
  }
}