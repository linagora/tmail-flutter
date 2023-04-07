import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class KeyboardUtils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void hideSystemKeyboardMobile() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}