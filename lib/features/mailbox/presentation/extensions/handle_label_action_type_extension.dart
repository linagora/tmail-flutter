import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleLabelActionTypeExtension on MailboxDashBoardController {
  Future<void> openLabelPopupMenuAction(
    BuildContext context,
    ImagePaths imagePaths,
    Label label,
    RelativeRect position,
  ) async {
    if (PlatformInfo.isWeb) {
      isPopupMenuOpened.value = true;
    }
    return labelController
      .openLabelMenuAction(
        context,
        imagePaths,
        label,
        position: position,
        (label, actionType) => _onPerformLabelActionType(
          context: context,
          label: label,
          actionType: actionType,
        ),
      )
      .whenComplete(() {
        if (PlatformInfo.isWeb) {
          isPopupMenuOpened.value = false;
        }
      });
  }

  void _onPerformLabelActionType({
    required BuildContext context,
    required Label label,
    required LabelActionType actionType,
  }) {
    labelController.handleLabelActionType(
      context: context,
      actionType: actionType,
      accountId: accountId.value,
      label: label,
    );
  }

  Future<void> openLabelContextMenuAction(
    BuildContext context,
    ImagePaths imagePaths,
    Label label,
  ) async {
    return labelController.openLabelMenuAction(
      context,
      imagePaths,
      label,
      (label, actionType) => _onPerformLabelActionType(
        context: context,
        label: label,
        actionType: actionType,
      ),
    );
  }
}
