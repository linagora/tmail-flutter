import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/popup_menu_item_label_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/labels/label_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin LabelContextMenuMixin on PopupContextMenuActionMixin {
  Future<void> openLabelContextMenuAction(
    BuildContext context,
    ImagePaths imagePaths,
    Label label,
    RelativeRect position,
    OnLabelActionTypeCallback onLabelActionTypeCallback,
  ) async {
    final listLabelAction = [LabelActionType.edit];

    final popupMenuItems = listLabelAction
        .map((actionType) => _buildLabelPopupMenuItem(
              label,
              actionType,
              AppLocalizations.of(context),
              imagePaths,
              onLabelActionTypeCallback,
            ))
        .toList();

    return openPopupMenuAction(
      context,
      position,
      popupMenuItems,
    );
  }

  PopupMenuItem _buildLabelPopupMenuItem(
    Label label,
    LabelActionType actionType,
    AppLocalizations appLocalizations,
    ImagePaths imagePaths,
    OnLabelActionTypeCallback onLabelActionTypeCallback,
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: PopupMenuItemActionWidget(
        menuAction: PopupMenuItemLabelAction(
          actionType,
          appLocalizations,
          imagePaths,
        ),
        menuActionClick: (menuAction) => _onPerformLabelActionType(
          label,
          actionType,
          onLabelActionTypeCallback,
        ),
      ),
    );
  }

  void _onPerformLabelActionType(
    Label label,
    LabelActionType actionType,
    OnLabelActionTypeCallback onLabelActionTypeCallback,
  ) {
    popBack();
    onLabelActionTypeCallback(label, actionType);
  }
}
