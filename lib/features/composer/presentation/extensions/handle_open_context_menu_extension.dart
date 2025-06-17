import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mark_as_important_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/composer_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/popup_menu_item_composer_type_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleOpenContextMenuExtension on ComposerController {
  void handleOpenContextMenu(BuildContext context, RelativeRect position) {
    final listSelectedComposerActionType = [
      if (isMarkAsImportant.isTrue)
        ComposerActionType.markAsImportant,
      if (hasRequestReadReceipt.isTrue)
        ComposerActionType.requestReadReceipt,
    ];

    final popupMenuItems = ComposerActionType.values.map((actionType) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          key: actionType.getContextMenuItemKey(),
          menuAction: PopupMenuItemComposerTypeAction(
            actionType,
            listSelectedComposerActionType,
            AppLocalizations.of(context),
            imagePaths,
          ),
          menuActionClick: (menuAction) {
            popBack();
            _handleComposerActionTypeClick(context, menuAction.action);
          },
        ),
      );
    }).toList();

    openPopupMenuAction(context, position, popupMenuItems);
  }

  void _handleComposerActionTypeClick(
    BuildContext context,
    ComposerActionType actionType,
  ) {
    switch (actionType) {
      case ComposerActionType.markAsImportant:
        toggleMarkAsImportant(context);
        break;
      case ComposerActionType.requestReadReceipt:
        toggleRequestReadReceipt(context);
        break;
      case ComposerActionType.saveAsDraft:
        handleClickSaveAsDraftsButton(context);
        break;
      case ComposerActionType.saveAsTemplate:
        handleClickSaveAsTemplateButton(context);
        break;
      case ComposerActionType.delete:
        handleClickDeleteComposer(context);
        break;
    }
  }
}
