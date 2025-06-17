import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/composer_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PopupMenuItemComposerTypeAction
    extends PopupMenuItemActionRequiredIconWithMultipleSelected<
        ComposerActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  PopupMenuItemComposerTypeAction(
    super.action,
    super.selectedActions,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getContextMenuIcon(imagePaths);

  @override
  String get actionName => action.getContextMenuTitle(appLocalizations);

  @override
  Color get actionIconColor => action.getContextMenuIconColor();

  @override
  Color get actionNameColor => action.getContextMenuTitleColor();

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
