import 'package:flutter/services.dart';

extension LogicalKeySetHelper on Set<LogicalKeyboardKey> {
  bool isKey(LogicalKeyboardKey key) => contains(key);

  bool isOnly(LogicalKeyboardKey key) => length == 1 && contains(key);

  bool isShift() =>
      contains(LogicalKeyboardKey.shiftLeft) ||
      contains(LogicalKeyboardKey.shiftRight);

  bool isShiftPlus(LogicalKeyboardKey key) => isShift() && contains(key);
}
