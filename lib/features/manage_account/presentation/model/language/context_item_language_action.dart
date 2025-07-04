import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemLanguageAction
    extends ContextMenuItemActionRequiredSelectedIcon<Locale> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemLanguageAction(
    super.action,
    super.selectedAction,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionName => '${action.getLanguageNameByCurrentLocale(appLocalizations)} - ${action.getSourceLanguageName()}';

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
