import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/email_rule_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemEmailRuleTypeAction
    extends ContextMenuItemActionRequiredIcon<EmailRuleActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemEmailRuleTypeAction(
    super.action,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getIcon(imagePaths);

  @override
  String get actionName => action.getName(appLocalizations);

  @override
  Color get actionIconColor => action.getIconColor();

  @override
  Color get actionNameColor => action.getNameColor();
}
