
import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/base/extensions/logical_key_set_helper.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension HandleShiftSelectionEmailExtension on ThreadController {
  void onKeyUpEventAction(KeyEvent event) {
    handleShiftSelectionEmail(event);
  }

  void handleShiftSelectionEmail(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    final shiftPressed = keysPressed.isShift();
    log('$runtimeType::handleShiftSelectionEmail:Event = ${event.runtimeType} keysPressed = $keysPressed | shiftPressed = $shiftPressed');
    if (event is KeyDownEvent && shiftPressed) {
      rangeSelectionMode = true;
    }
    if (event is KeyUpEvent && !shiftPressed) {
      rangeSelectionMode = false;
    }
  }
}