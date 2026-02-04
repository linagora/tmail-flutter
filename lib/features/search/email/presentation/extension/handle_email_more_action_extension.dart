import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_more_action_context_menu_mixin.dart';

extension HandleEmailMoreActionExtension on SearchEmailController {
  Future<void> handleEmailMoreAction(
    BuildContext context,
    PresentationEmail presentationEmail,
    RelativeRect? position,
    bool isLabelAvailable,
    List<Label>? listLabels,
  ) async {
    await openMoreActionContextMenu(
      EmailContextMenuParams(
        context: context,
        email: presentationEmail,
        imagePaths: imagePaths,
        isLabelAvailable: isLabelAvailable,
        labels: listLabels,
        position: position,
        openBottomSheetContextMenu: openBottomSheetContextMenuAction,
        openPopupMenu: (context, position, popupMenuWidget) =>
            popupMenuWidget.show(context, position),
        onHandleEmailByActionType: pressEmailAction,
        onSelectLabelAction: (label, isSelected) {
          final emailId = presentationEmail.id;
          if (emailId == null) {
            logWarning('HandleEmailMoreActionExtension::onSelectLabelAction: Email id is null');
            return;
          }
          mailboxDashBoardController.toggleLabelToEmail(
            emailId,
            label,
            isSelected,
          );
        },
        onCreateANewLabelAction: () {
          final emailId = presentationEmail.id;
          if (emailId == null) return;
          mailboxDashBoardController.labelController.handleLabelActionType(
            actionType: LabelActionType.create,
            accountId: accountId,
            onLabelActionCallback: (label) =>
                mailboxDashBoardController.toggleLabelToEmail(emailId, label, true),
          );
        },
      ),
    );
  }
}
