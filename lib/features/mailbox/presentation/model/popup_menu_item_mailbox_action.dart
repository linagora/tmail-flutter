import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PopupMenuItemMailboxAction
    extends PopupMenuItemActionRequiredIcon<MailboxActions> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  PopupMenuItemMailboxAction(
    super.action,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getContextMenuIcon(imagePaths);

  @override
  String get actionName => action.getContextMenuTitle(appLocalizations);

  @override
  Color get actionIconColor => action.getPopupMenuIconColor();

  @override
  Color get actionNameColor => action.getPopupMenuTitleColor();
}
