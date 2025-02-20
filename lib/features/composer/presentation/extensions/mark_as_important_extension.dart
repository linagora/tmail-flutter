
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension MarkAsImportantExtension on ComposerController {
  void toggleMarkAsImportant(BuildContext context) {
    isMarkAsImportant.toggle();

    appToast.showToastSuccessMessage(
        context,
        isMarkAsImportant.isTrue
            ? AppLocalizations.of(context).markAsImportantIsEnabled
            : AppLocalizations.of(context).markAsImportantIsDisabled);
  }
}