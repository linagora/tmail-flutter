import 'package:core/presentation/views/dialog/color_picker_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ColorDialogPicker {
  static final _instance = ColorDialogPicker._();

  factory ColorDialogPicker() => _instance;

  ColorDialogPicker._();

  final _isOpened = RxBool(false);

  RxBool get isOpened => _isOpened;

  Future<void> showTwakeColorPicker(
    BuildContext context,
    Color currentColor,
    {
      Function(Color?)? onSelectColor,
      VoidCallback? onResetToDefault,
    }
  ) async {
    _isOpened.value = true;
    final appLocalizations = AppLocalizations.of(context);

    return ColorPickerDialogBuilder(
      ValueNotifier<Color>(currentColor),
      title: appLocalizations.chooseAColor,
      textActionSetColor: appLocalizations.setColor,
      textActionResetDefault: appLocalizations.resetToDefault,
      textActionCancel: appLocalizations.cancel,
      cancelActionCallback: popBack,
      resetToDefaultActionCallback: () {
        onResetToDefault?.call();
        popBack();
      },
      setColorActionCallback: (selectedColor) {
        onSelectColor?.call(selectedColor);
        popBack();
      },
    ).show().whenComplete(() => _isOpened.value = false);
  }
}
