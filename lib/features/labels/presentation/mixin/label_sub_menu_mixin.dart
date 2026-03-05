import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';

mixin LabelSubMenuMixin {
  Widget? buildLabelSubmenuForEmail({
    required EmailActionType actionType,
    required ImagePaths imagePaths,
    required PresentationEmail presentationEmail,
    required List<Label>? labels,
    required OnSelectLabelAction onSelectLabelAction,
  }) {
    if (actionType == EmailActionType.labelAs && labels?.isNotEmpty == true) {
      final listLabels = labels ?? [];
      final emailLabels = presentationEmail.getLabelList(listLabels);
      return LabelListContextMenu(
        labelList: listLabels,
        emailLabels: emailLabels,
        imagePaths: imagePaths,
        onSelectLabelAction: onSelectLabelAction,
      );
    }
    return null;
  }

  bool shouldHandleAction(EmailActionType action) {
    if (action != EmailActionType.labelAs) {
      return true;
    }
    return PlatformInfo.isWebTouchDevice || PlatformInfo.isMobile;
  }
}
