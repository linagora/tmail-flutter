import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextMenuItemLabelAction
    extends ContextMenuItemActionRequiredIcon<LabelActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextMenuItemLabelAction(
    super.action,
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
}
