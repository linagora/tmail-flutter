import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailRecoveryController extends BaseController {
  EmailRecoveryController();

  void closeView(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }
}