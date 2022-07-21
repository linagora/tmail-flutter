
import 'package:core/presentation/views/dialog/color_picker_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

abstract class BaseRichTextController extends GetxController {

  void openMenuSelectColor(
    BuildContext context,
    Color currentColor,
    {Function(Color?)? onSelectColor}
  ) async {
    await ColorPickerDialogBuilder(
        context,
        currentColor,
        title: AppLocalizations.of(context).chooseAColor,
        textActionSetColor: AppLocalizations.of(context).setColor,
        textActionResetDefault: AppLocalizations.of(context).resetToDefault,
        textActionCancel: AppLocalizations.of(context).cancel,
        cancelActionCallback: () => popBack(),
        setColorActionCallback: (selectedColor) {
          onSelectColor?.call(selectedColor);
          popBack();
        }
    ).show();
  }
}